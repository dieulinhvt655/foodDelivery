import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/database/address_database_helper.dart';
import '../../../core/models/address_model.dart';
import '../../../core/providers/auth_provider.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  final AddressDatabaseHelper _dbHelper = AddressDatabaseHelper.instance;
  bool _isLoading = true;
  List<AddressModel> _addresses = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final account = auth.currentAccount;
      if (account == null || account.id == null) {
        setState(() {
          _addresses = [];
          _error = 'Please log in to manage addresses';
        });
        return;
      }
      final data = await _dbHelper.fetchAddresses(account.id!);
      if (!mounted) return;
      setState(() {
        _addresses = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setDefault(AddressModel address) async {
    try {
      final auth = context.read<AuthProvider>();
      final account = auth.currentAccount;
      if (account?.id == null) return;
      await _dbHelper.setDefaultAddress(userId: account!.id!, addressId: address.id!);
      await _loadAddresses();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _deleteAddress(AddressModel address) async {
    try {
      if (address.id == null) return;
      await _dbHelper.deleteAddress(address.id!);
      await _loadAddresses();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB800),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB800),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF6B35)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Delivery Address',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      ),
                    )
                  : _addresses.isEmpty
                      ? _EmptyAddresses(onAddTap: () async {
                          final added = await context.push<bool>('/addresses/new');
                          if (added == true) {
                            await _loadAddresses();
                          }
                        })
                      : Column(
                          children: [
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _loadAddresses,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(top: 8),
                                  itemCount: _addresses.length,
                                  itemBuilder: (context, index) {
                                    final address = _addresses[index];
                                    final isLast = index == _addresses.length - 1;
                                    return _AddressCard(
                                      address: address,
                                      onSetDefault: () => _setDefault(address),
                                      showDivider: !isLast,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final added = await context.push<bool>('/addresses/new');
                                      if (added == true) {
                                        await _loadAddresses();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF6B35),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                    ),
                                    child: const Text(
                                      'Add New Address',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
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

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses({required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E3),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.map_outlined, size: 72, color: Color(0xFFFF6B35)),
          ),
          const SizedBox(height: 32),
          const Text(
            'No delivery addresses yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Add a new address to speed up your checkout experience.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF7A7A7A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: onAddTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF6B35), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'Add New Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onSetDefault,
    required this.showDivider,
  });

  final AddressModel address;
  final VoidCallback onSetDefault;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: address.isDefault ? null : onSetDefault,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // House icon on the left
                const Icon(
                  Icons.home_outlined,
                  color: Color(0xFFFF6B35),
                  size: 24,
                ),
                const SizedBox(width: 16),
                // Address info in the middle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label (bold, dark gray)
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Address (lighter gray, smaller font)
                      Text(
                        address.address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Radio button on the right
                GestureDetector(
                  onTap: address.isDefault ? null : onSetDefault,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF6B35),
                        width: 2,
                      ),
                      color: address.isDefault ? const Color(0xFFFF6B35) : Colors.transparent,
                    ),
                    child: address.isDefault
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divider (light orange)
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: const Color(0xFFFFE0B3),
          ),
      ],
    );
  }
}

