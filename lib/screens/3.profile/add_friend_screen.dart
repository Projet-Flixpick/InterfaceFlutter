import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/friend_provider.dart';
import '../../providers/auth_provider.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({Key? key}) : super(key: key);
  static const routeName = '/add-friend';

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isSending = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validate);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validate);
    _emailController.dispose();
    super.dispose();
  }

  // Regex plus tolérant (gère + dans le local, TLD > 4, etc.)
  final _emailRegex = RegExp(r'^[\w\-.+]+@([\w\-]+\.)+[\w\-]{2,}$');

  void _validate() {
    final v = _emailController.text.trim();
    final ok = _emailRegex.hasMatch(v);
    if (ok != _isValid) {
      setState(() => _isValid = ok);
    }
  }

  Future<void> _sendRequest() async {
    if (_isSending) return;
    final email = _emailController.text.trim();
    if (!_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un email valide.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expirée. Veuillez vous reconnecter.')),
      );
      return;
    }

    setState(() => _isSending = true);
    FocusScope.of(context).unfocus();

    final friendProv = context.read<FriendProvider>();
    final error = await friendProv.sendFriendRequest(token, email);

    if (!mounted) return;
    setState(() => _isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error == null ? 'Demande envoyée.' : error)),
    );

    if (error == null) {
      _emailController.clear();
      _isValid = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un ami')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) => _isValid && !_isSending ? _sendRequest() : null,
                decoration: InputDecoration(
                  labelText: 'Email de l’ami',
                  hintText: 'ex. jean.dupont@mail.com',
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  errorText: _emailController.text.isEmpty || _isValid
                      ? null
                      : 'Adresse email invalide',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: (_isValid && !_isSending) ? _sendRequest : null,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.person_add),
                  label: const Text('Envoyer la demande'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
