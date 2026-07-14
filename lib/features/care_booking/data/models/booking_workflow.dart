import 'package:flutter/material.dart';

abstract class BookingWorkflow {
  String get name;
  String get description;
  List<String> get checkoutSteps;
  
  // Strategy actions
  void executeCheckout(BuildContext context, Map<String, dynamic> bookingDetails);
  Widget buildCheckoutSummary(BuildContext context, Map<String, dynamic> bookingDetails);
}

class QuickBookWorkflow implements BookingWorkflow {
  @override
  String get name => 'Quick Book';

  @override
  String get description => 'Immediate, single-tap booking for on-demand local services.';

  @override
  List<String> get checkoutSteps => ['Locate Provider', 'Select Service', 'Instant Pay'];

  @override
  void executeCheckout(BuildContext context, Map<String, dynamic> bookingDetails) {
    // Quick book check out implementation logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quick Book checkout complete!')),
    );
  }

  @override
  Widget buildCheckoutSummary(BuildContext context, Map<String, dynamic> bookingDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Instant Dispatch Scheduled', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Service charge flat rate: \$${bookingDetails['rate'] ?? '25'}'),
      ],
    );
  }
}

class VisitBasedWorkflow implements BookingWorkflow {
  @override
  String get name => 'Visit-based';

  @override
  String get description => 'Scheduled single or multi-date appointments with specific slots.';

  @override
  List<String> get checkoutSteps => ['Select Dates', 'Select Slots', 'Review & Pay'];

  @override
  void executeCheckout(BuildContext context, Map<String, dynamic> bookingDetails) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visit-based checkout complete!')),
    );
  }

  @override
  Widget buildCheckoutSummary(BuildContext context, Map<String, dynamic> bookingDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Scheduled Visit Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Date slots selected: ${bookingDetails['dates'] ?? 'N/A'}'),
        Text('Total visits: ${bookingDetails['visit_count'] ?? '1'}'),
      ],
    );
  }
}

class MonthlySubscriptionWorkflow implements BookingWorkflow {
  @override
  String get name => 'Monthly Support';

  @override
  String get description => 'Subscription-based reoccurring bookings with automated renewals.';

  @override
  List<String> get checkoutSteps => ['Subscription Details', 'Setup Autopay', 'Review Plan'];

  @override
  void executeCheckout(BuildContext context, Map<String, dynamic> bookingDetails) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscription setup complete!')),
    );
  }

  @override
  Widget buildCheckoutSummary(BuildContext context, Map<String, dynamic> bookingDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Monthly Auto-Renew Plan', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Pricing: \$${bookingDetails['monthly_rate'] ?? '350'}/month'),
        const Text('Billed automatically every 30 days.', style: TextStyle(fontStyle: FontStyle.italic)),
      ],
    );
  }
}

class LiveInCareWorkflow implements BookingWorkflow {
  @override
  String get name => 'Live-in Care';

  @override
  String get description => 'Specialized long-term care requiring custom contracts and onboarding.';

  @override
  List<String> get checkoutSteps => ['Contract Agreement', 'Medical History Onboarding', 'Advisor Matching', 'Approval'];

  @override
  void executeCheckout(BuildContext context, Map<String, dynamic> bookingDetails) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Live-in care request submitted to verification advisors.')),
    );
  }

  @override
  Widget buildCheckoutSummary(BuildContext context, Map<String, dynamic> bookingDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Long-term Live-in Care Contract', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('Custom agreement requires medical review.', style: TextStyle(color: Colors.red)),
      ],
    );
  }
}

class BookingWorkflowFactory {
  static BookingWorkflow getWorkflow(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'quick':
      case 'patient care':
      case 'live-in care':
        return LiveInCareWorkflow();
      case 'monthly support':
        return MonthlySubscriptionWorkflow();
      case 'visit-based':
      case 'visit':
      default:
        return VisitBasedWorkflow();
    }
  }
}
