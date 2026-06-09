import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/fiat_wallet_bloc.dart';
import '../bloc/fiat_wallet_event.dart';
import '../bloc/fiat_wallet_state.dart';
import '../widgets/fiat_balance_card.dart';

class FiatWalletHome extends StatelessWidget {
  final String userId;
  const FiatWalletHome({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: const Text(
          'Fiat Wallet',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: BlocProvider(
        create: (context) =>
            context.read<FiatWalletBloc>()..add(LoadFiatBalances(userId)),
        child: BlocConsumer<FiatWalletBloc, FiatWalletState>(
          listener: (context, state) {
            if (state is FiatWalletOperationSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is FiatWalletError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is FiatWalletLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.dev2Green,
                ),
              );
            }
            if (state is FiatWalletBalancesLoaded) {
              final balances = state.balances;
              if (balances.isEmpty) {
                return const Center(
                  child: Text(
                    'No fiat accounts yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: balances.length,
                      itemBuilder: (_, i) =>
                          FiatBalanceCard(account: balances[i]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/deposit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.dev2Green,
                            ),
                            child: const Text(
                              'Deposit',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/withdraw'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.dev2Green,
                            ),
                            child: const Text(
                              'Withdraw',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
