import 'dart:math';
import '../models/ai_model.dart';
import '../constants/app_constants.dart';

class AIService {
  static AIService? _instance;
  static AIService get instance {
    _instance ??= AIService._internal();
    return _instance!;
  }
  
  AIService._internal();

  final Random _random = Random();

  // Mock AI Price Suggestion
  Future<double> suggestBasePrice(String productName, double quantity, String location) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock price calculation based on product type and market conditions
    final basePrices = {
      'Rice': 45.0,
      'Wheat': 35.0,
      'Tomato': 25.0,
      'Onion': 30.0,
      'Potato': 20.0,
      'Apple': 120.0,
      'Banana': 60.0,
      'Carrot': 40.0,
      'Cabbage': 15.0,
      'Spinach': 35.0,
    };
    
    final basePrice = basePrices[productName] ?? 50.0;
    final marketVariation = (_random.nextDouble() - 0.5) * 10; // ±5 price variation
    return basePrice + marketVariation;
  }

  // Mock AI Crop Advisory
  Future<CropAdvisory> getCropAdvisory(String farmerId, String cropType, String location) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final weather = WeatherData(
      temperature: 25.0 + (_random.nextDouble() * 10),
      humidity: 60.0 + (_random.nextDouble() * 30),
      rainfall: _random.nextDouble() * 20,
      condition: ['Sunny', 'Cloudy', 'Rainy'][_random.nextInt(3)],
      forecast: List.generate(7, (index) => 
        WeatherForecast(
          date: DateTime.now().add(Duration(days: index + 1)),
          temperature: 20.0 + (_random.nextDouble() * 15),
          condition: ['Sunny', 'Cloudy', 'Rainy'][_random.nextInt(3)],
          rainfall: _random.nextDouble() * 15,
        )
      ),
    );

    final priceTrends = PriceTrends(
      product: cropType,
      currentPrice: 45.0 + (_random.nextDouble() * 20),
      historical: List.generate(30, (index) =>
        PricePoint(
          date: DateTime.now().subtract(Duration(days: 30 - index)),
          price: 40.0 + (_random.nextDouble() * 25),
        )
      ),
      forecast: List.generate(30, (index) =>
        PricePoint(
          date: DateTime.now().add(Duration(days: index + 1)),
          price: 42.0 + (_random.nextDouble() * 28),
        )
      ),
      trend: ['Increasing', 'Stable', 'Decreasing'][_random.nextInt(3)],
    );

    final recommendations = _getCropRecommendations(cropType, weather);

    return CropAdvisory(
      id: 'advisory_${DateTime.now().millisecondsSinceEpoch}',
      farmerId: farmerId,
      cropType: cropType,
      season: _getCurrentSeason(),
      weather: weather,
      recommendations: recommendations,
      expectedYield: 2.5 + (_random.nextDouble() * 2), // tons per hectare
      priceTrends: priceTrends,
      timestamp: DateTime.now(),
    );
  }

  // Mock AI Recommendations
  Future<List<AIRecommendation>> getRecommendations(String userId, String userRole) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final recommendations = <AIRecommendation>[];
    
    switch (userRole) {
      case AppConstants.roleFarmer:
        recommendations.addAll(_getFarmerRecommendations(userId));
        break;
      case AppConstants.roleDistributor:
        recommendations.addAll(_getDistributorRecommendations(userId));
        break;
      case AppConstants.roleRetailer:
        recommendations.addAll(_getRetailerRecommendations(userId));
        break;
      case AppConstants.roleConsumer:
        recommendations.addAll(_getConsumerRecommendations(userId));
        break;
    }
    
    return recommendations;
  }

  // Mock Chatbot Response
  Future<ChatMessage> getChatbotResponse(String userId, String message, String? imageUrl) async {
    await Future.delayed(const Duration(seconds: 1));
    
    String response;
    
    if (imageUrl != null) {
      response = _generateImageResponse(message);
    } else {
      response = _generateTextResponse(message);
    }
    
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      message: response,
      type: 'text',
      sender: 'ai',
      timestamp: DateTime.now(),
    );
  }

  // Mock AI Cost Prediction for Distributors
  Future<double> predictDeliveryCost(String origin, String destination, double distance, String vehicleType) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final baseCostPerKm = {
      'truck': 8.0,
      'van': 6.0,
      'motorcycle': 3.0,
    };
    
    final costPerKm = baseCostPerKm[vehicleType.toLowerCase()] ?? 5.0;
    final fuelMultiplier = 1.0 + (_random.nextDouble() * 0.2); // Fuel price variation
    final trafficMultiplier = 1.0 + (_random.nextDouble() * 0.3); // Traffic conditions
    
    return distance * costPerKm * fuelMultiplier * trafficMultiplier;
  }

  // Mock AI Margin Suggestion for Retailers
  Future<double> suggestMargin(String productName, String location, double basePrice) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final demandFactor = 0.8 + (_random.nextDouble() * 0.4); // 0.8 to 1.2
    final competitionFactor = 0.9 + (_random.nextDouble() * 0.2); // 0.9 to 1.1
    final seasonalFactor = 0.95 + (_random.nextDouble() * 0.1); // 0.95 to 1.05
    
    final suggestedMargin = 0.15 + (demandFactor * competitionFactor * seasonalFactor * 0.1);
    return suggestedMargin.clamp(0.05, 0.35); // 5% to 35% margin
  }

  List<String> _getCropRecommendations(String cropType, WeatherData weather) {
    final recommendations = <String>[];
    
    if (weather.rainfall < 5) {
      recommendations.add('Consider irrigation due to low rainfall forecast');
    }
    
    if (weather.temperature > 35) {
      recommendations.add('Provide shade during peak hours');
    }
    
    if (weather.humidity > 80) {
      recommendations.add('Monitor for fungal diseases');
    }
    
    recommendations.addAll([
      'Apply organic fertilizer for better yield',
      'Regular soil testing recommended',
      'Consider companion planting for natural pest control',
    ]);
    
    return recommendations;
  }

  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'Summer';
    if (month >= 6 && month <= 9) return 'Monsoon';
    if (month >= 10 && month <= 12) return 'Post-Monsoon';
    return 'Winter';
  }

  List<AIRecommendation> _getFarmerRecommendations(String userId) {
    return [
      AIRecommendation(
        id: 'rec_1',
        userId: userId,
        type: 'crop_suggestion',
        title: 'Best Crop for This Season',
        description: 'Based on weather patterns, consider planting tomatoes this season',
        confidence: 0.85,
        data: {'crop': 'tomato', 'expected_yield': 3.2},
        timestamp: DateTime.now(),
      ),
      AIRecommendation(
        id: 'rec_2',
        userId: userId,
        type: 'price_alert',
        title: 'Price Increase Alert',
        description: 'Onion prices expected to rise by 15% next month',
        confidence: 0.72,
        data: {'product': 'onion', 'price_change': 15},
        timestamp: DateTime.now(),
      ),
    ];
  }

  List<AIRecommendation> _getDistributorRecommendations(String userId) {
    return [
      AIRecommendation(
        id: 'rec_3',
        userId: userId,
        type: 'route_optimization',
        title: 'Optimized Route Available',
        description: 'Take Route B to save 25 minutes and ₹120 in fuel',
        confidence: 0.91,
        data: {'route': 'B', 'time_saved': 25, 'cost_saved': 120},
        timestamp: DateTime.now(),
      ),
    ];
  }

  List<AIRecommendation> _getRetailerRecommendations(String userId) {
    return [
      AIRecommendation(
        id: 'rec_4',
        userId: userId,
        type: 'demand_forecast',
        title: 'High Demand Expected',
        description: 'Increase tomato stock by 40% for this weekend',
        confidence: 0.78,
        data: {'product': 'tomato', 'demand_increase': 40},
        timestamp: DateTime.now(),
      ),
    ];
  }

  List<AIRecommendation> _getConsumerRecommendations(String userId) {
    return [
      AIRecommendation(
        id: 'rec_5',
        userId: userId,
        type: 'price_comparison',
        title: 'Better Deal Available',
        description: 'Get fresh tomatoes 15% cheaper at Green Market, 2km away',
        confidence: 0.82,
        data: {'product': 'tomato', 'savings': 15, 'location': 'Green Market'},
        timestamp: DateTime.now(),
      ),
    ];
  }

  String _generateTextResponse(String message) {
    final responses = [
      'I can help you with agricultural queries. What would you like to know?',
      'Based on current market trends, I recommend focusing on seasonal crops.',
      'For better yields, consider implementing drip irrigation systems.',
      'Quality seeds and proper fertilization are key to successful farming.',
      'Monitor weather patterns regularly for optimal planting schedules.',
    ];
    
    return responses[_random.nextInt(responses.length)];
  }

  String _generateImageResponse(String message) {
    return 'I can see the image you uploaded. This appears to be a crop/plant. Based on the visual analysis, I recommend checking for signs of pest damage and ensuring adequate water supply.';
  }
}