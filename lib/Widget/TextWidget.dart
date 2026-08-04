import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthWidgets {
  // Private Helper Style
  static BoxDecoration inputBoxDecoration() {
    return BoxDecoration(
      color: const Color(0xFFFAFAFE),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );
  }

  static Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isPhoneNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: isPhoneNumber ? 11 : null,

      inputFormatters: isPhoneNumber
          ? [
              LengthLimitingTextInputFormatter(11),
              FilteringTextInputFormatter.digitsOnly,
            ]
          : null,

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF6C5CE7), size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF7F7FD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  static Widget circularIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }

  static Widget languageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.language, size: 16, color: Colors.black87),
          SizedBox(width: 4),
          Text(
            "English",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black87),
        ],
      ),
    );
  }

  static Widget buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "or continue with",
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }

  static Widget socialButton(String label, IconData icon, Color color) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  static Widget privacyMattersCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF5A42EC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Privacy Matters",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  "We respect your privacy and keep your data safe and secure.",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildGoogleSignInButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Spans the full width of its parent container
        height: 52, // Standard professional button height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: NetworkImage('https://google.com'),
              width: 22,
              height: 22,
            ),
            SizedBox(width: 12),

            Text(
              "Continue with Google",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
