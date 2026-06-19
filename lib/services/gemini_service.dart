import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class GeminiReceiptResult {
  final double amount;
  final String title;
  final String type; // 'expense' or 'income'
  final DateTime? date;

  GeminiReceiptResult({
    required this.amount,
    required this.title,
    required this.type,
    this.date,
  });

  factory GeminiReceiptResult.fromJson(Map<String, dynamic> json) {
    return GeminiReceiptResult(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      title: json['title'] as String? ?? 'Сканированный чек',
      type: json['type'] as String? ?? 'expense',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
    );
  }
}

class GeminiService {
  Future<GeminiReceiptResult?> analyzeReceipt(XFile imageFile, String apiKey) async {
    if (apiKey.isEmpty) {
      throw Exception('API ключ не задан. Пожалуйста, добавьте его в настройках.');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      final bytes = await imageFile.readAsBytes();
      
      // Determine mimeType from file extension as fallback
      String mimeType = imageFile.mimeType ?? 'image/jpeg';
      if (imageFile.name.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      }

      final prompt = TextPart('''
Analyze this image of a receipt or bank statement screenshot (often from Kaspi, Halyk, or other local banks).
Extract the following information and return ONLY a valid JSON object without any markdown formatting or extra text:
- amount: The total transaction amount (number only, ignore currency symbols)
- title: The name of the merchant, sender, or receiver (string). Extract the real name of the place or person.
- type: 'expense' if money was spent/sent/transferred away, 'income' if money was received/deposited (string)
- date: The transaction date in ISO 8601 format (YYYY-MM-DD), if present. Otherwise null.

Example output:
{
  "amount": 1500.50,
  "title": "Magnum Supermarket",
  "type": "expense",
  "date": "2023-10-25"
}
''');

      final imageParts = [
        DataPart(mimeType, bytes),
      ];

      final response = await model.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);

      if (response.text != null) {
        String text = response.text!.trim();
        // Remove markdown formatting if Gemini includes it
        if (text.startsWith('```json')) {
          text = text.substring(7);
        } else if (text.startsWith('```')) {
          text = text.substring(3);
        }
        if (text.endsWith('```')) {
          text = text.substring(0, text.length - 3);
        }
        text = text.trim();

        final data = jsonDecode(text);
        return GeminiReceiptResult.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Gemini API Error: $e');
      throw Exception('Не удалось распознать чек: $e');
    }
  }
}
