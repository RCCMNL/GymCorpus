import 'dart:ui';
import 'package:flutter/material.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.theme});
  final ThemeData theme;
  @override
  Widget build(BuildContext context) => Stack(children: [
    Positioned(top: -120, right: -80, child: _g(350, theme.colorScheme.primary, 0.12)),
    Positioned(bottom: -100, left: -60, child: _g(300, theme.colorScheme.secondary, 0.06)),
  ]);
  Widget _g(double s, Color c, double a) => Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c.withValues(alpha: a), Colors.transparent])));
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) { final t = Theme.of(context);
    return ClipRRect(borderRadius: BorderRadius.circular(20), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [t.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5), t.colorScheme.surface.withValues(alpha: 0.7)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: t.colorScheme.primary.withValues(alpha: 0.08))), child: child))); }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({super.key, required this.controller, required this.hint, required this.icon, this.obscure = false, this.autofill, this.keyboardType, this.action, this.onSubmitted, this.suffixIcon});
  final TextEditingController controller; final String hint; final IconData icon; final bool obscure; final Iterable<String>? autofill; final TextInputType? keyboardType; final TextInputAction? action; final void Function(String)? onSubmitted; final Widget? suffixIcon;
  @override
  Widget build(BuildContext context) { final t = Theme.of(context);
    return TextField(controller: controller, obscureText: obscure, autofillHints: autofill, keyboardType: keyboardType, textInputAction: action, onSubmitted: onSubmitted, style: TextStyle(color: t.colorScheme.onSurface, fontFamily: 'Inter'), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: t.colorScheme.outline), prefixIcon: Icon(icon, size: 18, color: t.colorScheme.outline), suffixIcon: suffixIcon, filled: true, fillColor: t.colorScheme.surfaceContainerHighest, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.colorScheme.primary.withValues(alpha: 0.4), width: 1.5)))); }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({super.key, required this.label, required this.isLoading, required this.onPressed});
  final String label; final bool isLoading; final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) { final t = Theme.of(context);
    return SizedBox(width: double.infinity, child: ElevatedButton(onPressed: isLoading ? null : onPressed, style: ElevatedButton.styleFrom(backgroundColor: t.colorScheme.primary, foregroundColor: t.colorScheme.onPrimary, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 6, shadowColor: t.colorScheme.primary.withValues(alpha: 0.35)), child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Lexend', fontSize: 15)))); }
}

class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({super.key, required this.logo, required this.label, this.onTap});
  final Widget logo; final String label; final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) { final t = Theme.of(context);
    return Material(color: t.colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(14), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(border: Border.all(color: t.colorScheme.outlineVariant.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(14)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [logo, const SizedBox(width: 10), Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'))])))); }
}

Widget authLabel(ThemeData t, String s) => Padding(padding: const EdgeInsets.only(left: 4), child: Text(s.toUpperCase(), style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1.5)));

Widget authDivider(ThemeData t, String s) { final l = Expanded(child: Container(height: 1, color: t.colorScheme.outlineVariant.withValues(alpha: 0.15))); return Row(children: [l, Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text(s, style: t.textTheme.labelSmall)), l]); }
