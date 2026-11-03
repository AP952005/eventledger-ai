/// PayGo — Financial Services Screen
/// Loans, Insurance, Stocks, Cards category grids.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/section_card.dart';
import '../../widgets/icon_grid.dart';

class FinancialServicesScreen extends StatelessWidget {
  const FinancialServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Services'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 8),

            SectionCard(
              title: 'Loans',
              child: IconGrid(
                items: [
                  IconGridItem(icon: Icons.credit_score_rounded, label: 'PayGo Postpaid'),
                  IconGridItem(icon: Icons.currency_rupee_rounded, label: 'Get Loan'),
                  IconGridItem(icon: Icons.trending_up_rounded, label: 'Loan on MF'),
                  IconGridItem(icon: Icons.workspace_premium_rounded, label: 'Gold Loan'),
                ],
              ),
            ),

            SectionCard(
              title: 'Insurance',
              child: IconGrid(
                items: [
                  IconGridItem(icon: Icons.two_wheeler_rounded, label: 'Bike Insurance'),
                  IconGridItem(icon: Icons.directions_car_rounded, label: 'Car Insurance'),
                  IconGridItem(icon: Icons.health_and_safety_rounded, label: 'Health Insurance'),
                  IconGridItem(icon: Icons.verified_user_rounded, label: 'Insurance Premium'),
                ],
              ),
            ),

            SectionCard(
              title: 'Stocks & Mutual Funds',
              child: IconGrid(
                items: [
                  IconGridItem(icon: Icons.show_chart_rounded, label: 'Mutual Fund'),
                  IconGridItem(icon: Icons.candlestick_chart_rounded, label: 'Stocks'),
                  IconGridItem(icon: Icons.auto_graph_rounded, label: 'ETFs'),
                  IconGridItem(icon: Icons.trending_up_rounded, label: 'MTF @ 7.99%'),
                ],
              ),
            ),

            SectionCard(
              title: 'Cards',
              child: IconGrid(
                columns: 3,
                items: [
                  IconGridItem(icon: Icons.add_card_rounded, label: 'Get Credit Card'),
                  IconGridItem(icon: Icons.payment_rounded, label: 'Pay CC Bill'),
                  IconGridItem(icon: Icons.link_rounded, label: 'Link RuPay to UPI'),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
