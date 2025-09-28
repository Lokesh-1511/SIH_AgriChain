import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomerAnalyticsScreen extends StatefulWidget {
  const CustomerAnalyticsScreen({super.key});

  @override
  State<CustomerAnalyticsScreen> createState() =>
      _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends State<CustomerAnalyticsScreen> {
  String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Analytics'),
        backgroundColor: AppColors.retailerPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _exportReport(context),
            icon: const Icon(Icons.file_download),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Row(
              children: [
                Text(
                  'Analytics Period: ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    isExpanded: true,
                    items:
                        [
                              'This Week',
                              'This Month',
                              'Last 3 Months',
                              'This Year',
                            ]
                            .map(
                              (period) => DropdownMenuItem(
                                value: period,
                                child: Text(period),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Key Metrics Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.retailerPrimary,
                    AppColors.retailerPrimary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.retailerPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Total Customers',
                      '1,234',
                      Icons.people,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'New This Month',
                      '87',
                      Icons.person_add,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Retention Rate',
                      '78%',
                      Icons.repeat,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Customer Segmentation
            Text(
              'Customer Segmentation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildSegmentCard(
                  'Regular Customers',
                  '456',
                  '37%',
                  AppColors.success,
                ),
                _buildSegmentCard(
                  'Occasional Buyers',
                  '543',
                  '44%',
                  AppColors.info,
                ),
                _buildSegmentCard(
                  'New Customers',
                  '178',
                  '14%',
                  AppColors.warning,
                ),
                _buildSegmentCard(
                  'VIP Customers',
                  '57',
                  '5%',
                  AppColors.retailerPrimary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Top Customers
            Text(
              'Top Customers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _topCustomers
                    .map((customer) => _buildCustomerItem(customer))
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Purchase Patterns
            Text(
              'Purchase Patterns',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPatternRow('Most Popular Time', '10:00 AM - 12:00 PM'),
                  const Divider(),
                  _buildPatternRow('Average Basket Size', '₹847'),
                  const Divider(),
                  _buildPatternRow('Peak Shopping Day', 'Saturday'),
                  const Divider(),
                  _buildPatternRow('Most Bought Category', 'Fresh Vegetables'),
                  const Divider(),
                  _buildPatternRow('Average Visit Frequency', '2.3 times/week'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Customer Satisfaction
            Text(
              'Customer Satisfaction',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '4.6 ★',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.retailerPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Average Rating',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on 1,456 reviews',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRatingBar('5★', 0.68),
                      _buildRatingBar('4★', 0.22),
                      _buildRatingBar('3★', 0.07),
                      _buildRatingBar('2★', 0.02),
                      _buildRatingBar('1★', 0.01),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Customer Feedback
            Text(
              'Recent Feedback',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            ..._recentFeedback.map((feedback) => _buildFeedbackCard(feedback)),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewDetailedReport(context),
                    icon: const Icon(Icons.analytics),
                    label: const Text('Detailed Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.retailerPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sendSurvey(context),
                    icon: const Icon(Icons.quiz),
                    label: const Text('Send Survey'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSegmentCard(
    String title,
    String count,
    String percentage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.people, color: color, size: 20),
              ),
              Text(
                percentage,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerItem(Map<String, dynamic> customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.textSecondary.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.retailerPrimary.withOpacity(0.1),
            child: Text(
              customer['name'][0],
              style: TextStyle(
                color: AppColors.retailerPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${customer['visits']} visits • ${customer['category']}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${customer['totalSpent']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.retailerPrimary,
                ),
              ),
              Text(
                'Total spent',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String rating, double percentage) {
    return Column(
      children: [
        Text(rating, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.retailerPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(percentage * 100).toInt()}%',
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.retailerPrimary.withOpacity(0.1),
                child: Text(
                  feedback['customerName'][0],
                  style: TextStyle(
                    color: AppColors.retailerPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback['customerName'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < feedback['rating']
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feedback['date'],
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback['comment'],
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _exportReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting customer analytics report...')),
    );
  }

  void _viewDetailedReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detailed customer report coming soon!')),
    );
  }

  void _sendSurvey(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer survey feature coming soon!')),
    );
  }

  static final List<Map<String, dynamic>> _topCustomers = [
    {
      'name': 'Priya Sharma',
      'visits': 45,
      'totalSpent': '12,340',
      'category': 'VIP',
    },
    {
      'name': 'Raj Patel',
      'visits': 38,
      'totalSpent': '9,850',
      'category': 'Regular',
    },
    {
      'name': 'Anita Kumar',
      'visits': 42,
      'totalSpent': '11,200',
      'category': 'VIP',
    },
    {
      'name': 'Suresh Gupta',
      'visits': 29,
      'totalSpent': '7,650',
      'category': 'Regular',
    },
    {
      'name': 'Maya Singh',
      'visits': 31,
      'totalSpent': '8,920',
      'category': 'Regular',
    },
  ];

  static final List<Map<String, dynamic>> _recentFeedback = [
    {
      'customerName': 'Arjun Mehta',
      'rating': 5,
      'comment':
          'Great quality products and excellent service! Fresh vegetables always available.',
      'date': '2 days ago',
    },
    {
      'customerName': 'Kavita Joshi',
      'rating': 4,
      'comment':
          'Good variety of products. Could improve packaging for fragile items.',
      'date': '1 week ago',
    },
    {
      'customerName': 'Rohit Das',
      'rating': 5,
      'comment':
          'Best prices in the area. Staff is very helpful and knowledgeable.',
      'date': '1 week ago',
    },
  ];
}
