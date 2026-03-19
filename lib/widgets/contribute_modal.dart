import 'package:flutter/material.dart';
import '../services/complaint_service.dart';
import '../services/auth_service.dart';

class ContributeModal extends StatefulWidget {
  final String complaintId;
  final String complaintTitle;
  final VoidCallback? onSuccess;

  /// When set, contribution cannot exceed [targetFund] - [fundCollected].
  final double? targetFund;

  /// Amount already raised (defaults to 0).
  final double fundCollected;

  const ContributeModal({
    super.key,
    required this.complaintId,
    required this.complaintTitle,
    this.onSuccess,
    this.targetFund,
    this.fundCollected = 0,
  });

  @override
  State<ContributeModal> createState() => _ContributeModalState();
}

class _ContributeModalState extends State<ContributeModal> {
  final TextEditingController _amountController = TextEditingController();
  final ComplaintService _complaintService = ComplaintService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleContribute() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amount must be at least ₹1'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Cannot contribute more than (funding goal - already collected)
    final goal = widget.targetFund;
    if (goal != null && goal > 0) {
      final collected = widget.fundCollected;
      final remaining = goal - collected;
      const eps = 1e-6;
      if (remaining <= eps) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funding goal has already been reached'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (amount > remaining + eps) {
        final remLabel = (remaining - remaining.round()).abs() < 1e-6
            ? remaining.round().toString()
            : remaining.toStringAsFixed(2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Amount cannot exceed ₹$remLabel (remaining toward the goal)',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Get current user
    final user = await _authService.getStoredUser();
    if (user == null || !user.isCustomer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in as a customer to contribute'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _complaintService.contribute(
        customerId: user.id,
        complaintId: widget.complaintId,
        amount: amount,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully contributed ₹${amount.toStringAsFixed(0)}!'),
              backgroundColor: Colors.green,
            ),
          );
          if (widget.onSuccess != null) {
            widget.onSuccess!();
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to contribute'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF136AF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFF136AF6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contribute',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.complaintTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter Contribution Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Enter amount (₹)',
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                    color: Color(0xFF136AF6),
                    size: 22,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final goal = widget.targetFund;
                final lines = <String>['Minimum contribution: ₹1'];
                if (goal != null && goal > 0) {
                  final remaining = goal - widget.fundCollected;
                  if (remaining > 1e-6) {
                    final remLabel = (remaining - remaining.round()).abs() < 1e-6
                        ? remaining.round().toString()
                        : remaining.toStringAsFixed(2);
                    lines.add('Maximum toward goal: ₹$remLabel');
                  }
                }
                return Text(
                  lines.join('\n'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF136AF6), Color(0xFF0D5AE0)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF136AF6).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleContribute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Contribute',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
