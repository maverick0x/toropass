import 'package:flutter/material.dart';
import 'package:toropass_client/toropass_client.dart';

void main() {
  runApp(const ToroPassClientExampleApp());
}

class ToroPassClientExampleApp extends StatelessWidget {
  const ToroPassClientExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToroPass Client Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const ToroPassExampleScreen(),
    );
  }
}

class ToroPassExampleScreen extends StatefulWidget {
  const ToroPassExampleScreen({super.key});

  @override
  State<ToroPassExampleScreen> createState() => _ToroPassExampleScreenState();
}

class _ToroPassExampleScreenState extends State<ToroPassExampleScreen> {
  final _clientIdController = TextEditingController(
    text: 'toro_client_c9b31514f78a7ce1aed5bb0a',
  );
  final _issuerBaseUrlController = TextEditingController(
    text: "http://localhost:3000/api/v1",
  );
  final _appNameController = TextEditingController(text: 'Example');

  static final Uri _redirectUri = Uri.parse('toropassclient://oauth/callback');

  ToroPassAuthResult? _lastResult;
  ToroPassAuthorizationRequest? _lastRequest;
  ToroPassOAuthSession? _session;
  String? _latestCode;
  bool _isAuthorizing = false;
  bool _isExchanging = false;
  bool _isFetchingProfile = false;

  ToroPassClient get _client => ToroPassClient(
    config: ToroPassClientConfig(
      clientId: _clientIdController.text,
      redirectUri: _redirectUri,
      issuerBaseUrl: Uri.parse(_issuerBaseUrlController.text.trim()),
    ),
  );

  @override
  void dispose() {
    _clientIdController.dispose();
    _issuerBaseUrlController.dispose();
    _appNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _lastResult?.toStatusMessage();

    return Scaffold(
      appBar: AppBar(title: const Text('ToroPass Client Example')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildIntro(context),
            const SizedBox(height: 20),
            _buildConfigCard(),
            const SizedBox(height: 20),
            _buildQuickFlowCard(),
            const SizedBox(height: 20),
            _buildManualFlowCard(),
            const SizedBox(height: 20),
            _buildStatusCard(status),
            const SizedBox(height: 20),
            _buildSessionCard(),
            const SizedBox(height: 20),
            _buildChecklistCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'End-to-end wallet OAuth test harness',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Use this example to launch ToroPass Wallet, receive the callback, '
              'exchange authorization codes, and validate profile access with a real issuer setup.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OAuth Config',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _clientIdController,
              decoration: const InputDecoration(
                labelText: 'Client ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _appNameController,
              decoration: const InputDecoration(
                labelText: 'App Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _issuerBaseUrlController,
              decoration: const InputDecoration(
                labelText: 'Issuer Base URL',
                border: OutlineInputBorder(),
                helperText:
                    'Example: https://api.toropass.app/api/v1 or http://localhost:3000/api/v1',
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Callback URI',
                border: OutlineInputBorder(),
              ),
              child: SelectableText(_redirectUri.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFlowCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Flow',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Runs launch, callback, code exchange, and profile fetch in one step.',
            ),
            const SizedBox(height: 16),
            ToroPassButton(
              client: _client,
              appName: _appNameController.text.trim(),
              label: 'Verify Identity',
              onResult: _handleQuickFlowResult,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualFlowCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manual Flow',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use this path to inspect the raw code, retry exchange, or fetch profile later.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: _isAuthorizing ? null : _startAuthorizationOnly,
                  child: Text(
                    _isAuthorizing
                        ? 'Waiting for callback...'
                        : 'Authorize Only',
                  ),
                ),
                FilledButton.tonal(
                  onPressed: _isExchanging || _latestCode == null
                      ? null
                      : _exchangeStoredCode,
                  child: Text(
                    _isExchanging ? 'Exchanging...' : 'Exchange Stored Code',
                  ),
                ),
                OutlinedButton(
                  onPressed: _isFetchingProfile || _session == null
                      ? null
                      : _fetchProfile,
                  child: Text(
                    _isFetchingProfile ? 'Refreshing...' : 'Fetch Profile',
                  ),
                ),
                TextButton(
                  onPressed: _clearSession,
                  child: const Text('Clear Session'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Latest code', _latestCode ?? 'None yet'),
            _buildInfoRow(
              'Last request state',
              _lastRequest?.state ?? 'None yet',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ToroPassStatusMessage? status) {
    final tone = status?.tone ?? ToroPassStatusTone.info;
    final color = switch (tone) {
      ToroPassStatusTone.success => Colors.green,
      ToroPassStatusTone.info => Colors.blue,
      ToroPassStatusTone.warning => Colors.orange,
      ToroPassStatusTone.error => Colors.red,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: color),
                const SizedBox(width: 8),
                Text(
                  status?.title ?? 'No result yet',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              status?.message ??
                  'Run either the quick flow or manual flow to capture a live ToroPass result.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard() {
    final profile = _session?.profile;
    final wallet = profile?.wallet;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Latest Session',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Access token',
              _session?.token.accessToken ?? 'No token yet',
            ),
            _buildInfoRow('User ID', profile?.id ?? 'No profile yet'),
            _buildInfoRow(
              'KYC verified',
              profile == null ? 'No profile yet' : '${profile.kycVerified}',
            ),
            _buildInfoRow(
              'Wallet address',
              wallet?.address ?? 'No profile yet',
            ),
            _buildInfoRow('TNS name', wallet?.tnsName ?? 'No profile yet'),
            _buildInfoRow('Network', wallet?.network ?? 'No profile yet'),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistCard() {
    const items = [
      'Approve while already logged in',
      'Approve after wallet sign-in redirect',
      'Deny from the permission screen',
      'Cancel with the top-right X or system back',
      'Exchange the same stored code twice',
      'Fetch profile with the returned OAuth token',
      'Revoke consent in ToroPass Wallet, then retry profile fetch',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phase 6 Manual Checklist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle_outline, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          SelectableText(value),
        ],
      ),
    );
  }

  Future<void> _startAuthorizationOnly() async {
    setState(() => _isAuthorizing = true);

    try {
      final request = await _client.launchWallet(
        appName: _appNameController.text.trim(),
      );

      if (request == null) {
        _setResult(
          const ToroPassAuthTransportError(
            message: 'ToroPass Wallet is not installed or could not be opened.',
          ),
        );
        return;
      }

      setState(() => _lastRequest = request);
      final result = await _client.waitForCallback(request);
      _setResult(result);

      if (result case ToroPassAuthorizationCodeReceived(:final code)) {
        setState(() => _latestCode = code);
      }
    } catch (error, stackTrace) {
      _setResult(
        ToroPassAuthTransportError(
          message: 'Manual authorization failed.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAuthorizing = false);
      }
    }
  }

  Future<void> _exchangeStoredCode() async {
    final code = _latestCode;
    if (code == null) return;

    setState(() => _isExchanging = true);

    try {
      final session = await _client.exchangeAuthorizationCode(code: code);
      setState(() => _session = session);
      _setResult(
        ToroPassAuthSuccess(token: session.token, profile: session.profile),
      );
    } catch (error, stackTrace) {
      _setResult(
        ToroPassAuthTransportError(
          message: error is ToroPassException
              ? error.message
              : 'Code exchange failed.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExchanging = false);
      }
    }
  }

  Future<void> _fetchProfile() async {
    final token = _session?.token.accessToken;
    if (token == null) return;

    setState(() => _isFetchingProfile = true);

    try {
      final profile = await _client.fetchProfile(accessToken: token);
      final session = ToroPassOAuthSession(
        token: _session!.token,
        profile: profile,
      );
      setState(() => _session = session);
      _setResult(
        ToroPassAuthSuccess(token: session.token, profile: session.profile),
      );
    } catch (error, stackTrace) {
      _setResult(
        ToroPassAuthTransportError(
          message: error is ToroPassException
              ? error.message
              : 'Profile fetch failed.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isFetchingProfile = false);
      }
    }
  }

  void _handleQuickFlowResult(ToroPassAuthResult result) {
    _setResult(result);

    if (result case ToroPassAuthSuccess()) {
      setState(() {
        _session = ToroPassOAuthSession(
          token: result.token,
          profile: result.profile,
        );
      });
    }
  }

  void _setResult(ToroPassAuthResult result) {
    if (!mounted) return;
    setState(() => _lastResult = result);
  }

  void _clearSession() {
    setState(() {
      _lastResult = null;
      _lastRequest = null;
      _session = null;
      _latestCode = null;
    });
  }
}
