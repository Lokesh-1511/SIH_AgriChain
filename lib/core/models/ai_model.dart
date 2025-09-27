class AIRecommendation {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String description;
  final double confidence;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl;

  AIRecommendation({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.data,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
      data: json['data'] ?? {},
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['is_read'] ?? false,
      actionUrl: json['action_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'description': description,
      'confidence': confidence,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'action_url': actionUrl,
    };
  }
}

class CropAdvisory {
  final String id;
  final String farmerId;
  final String cropType;
  final String season;
  final WeatherData weather;
  final List<String> recommendations;
  final double expectedYield;
  final PriceTrends priceTrends;
  final DateTime timestamp;

  CropAdvisory({
    required this.id,
    required this.farmerId,
    required this.cropType,
    required this.season,
    required this.weather,
    required this.recommendations,
    required this.expectedYield,
    required this.priceTrends,
    required this.timestamp,
  });

  factory CropAdvisory.fromJson(Map<String, dynamic> json) {
    return CropAdvisory(
      id: json['id'],
      farmerId: json['farmer_id'],
      cropType: json['crop_type'],
      season: json['season'],
      weather: WeatherData.fromJson(json['weather']),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      expectedYield: json['expected_yield']?.toDouble() ?? 0.0,
      priceTrends: PriceTrends.fromJson(json['price_trends']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'crop_type': cropType,
      'season': season,
      'weather': weather.toJson(),
      'recommendations': recommendations,
      'expected_yield': expectedYield,
      'price_trends': priceTrends.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class WeatherData {
  final double temperature;
  final double humidity;
  final double rainfall;
  final String condition;
  final List<WeatherForecast> forecast;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.condition,
    required this.forecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['temperature']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
      rainfall: json['rainfall']?.toDouble() ?? 0.0,
      condition: json['condition'] ?? '',
      forecast: (json['forecast'] as List<dynamic>? ?? [])
          .map((f) => WeatherForecast.fromJson(f))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
      'condition': condition,
      'forecast': forecast.map((f) => f.toJson()).toList(),
    };
  }
}

class WeatherForecast {
  final DateTime date;
  final double temperature;
  final String condition;
  final double rainfall;

  WeatherForecast({
    required this.date,
    required this.temperature,
    required this.condition,
    required this.rainfall,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.parse(json['date']),
      temperature: json['temperature']?.toDouble() ?? 0.0,
      condition: json['condition'] ?? '',
      rainfall: json['rainfall']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'temperature': temperature,
      'condition': condition,
      'rainfall': rainfall,
    };
  }
}

class PriceTrends {
  final String product;
  final double currentPrice;
  final List<PricePoint> historical;
  final List<PricePoint> forecast;
  final String trend;

  PriceTrends({
    required this.product,
    required this.currentPrice,
    required this.historical,
    required this.forecast,
    required this.trend,
  });

  factory PriceTrends.fromJson(Map<String, dynamic> json) {
    return PriceTrends(
      product: json['product'],
      currentPrice: json['current_price']?.toDouble() ?? 0.0,
      historical: (json['historical'] as List<dynamic>? ?? [])
          .map((p) => PricePoint.fromJson(p))
          .toList(),
      forecast: (json['forecast'] as List<dynamic>? ?? [])
          .map((p) => PricePoint.fromJson(p))
          .toList(),
      trend: json['trend'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'current_price': currentPrice,
      'historical': historical.map((p) => p.toJson()).toList(),
      'forecast': forecast.map((p) => p.toJson()).toList(),
      'trend': trend,
    };
  }
}

class PricePoint {
  final DateTime date;
  final double price;

  PricePoint({
    required this.date,
    required this.price,
  });

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      date: DateTime.parse(json['date']),
      price: json['price']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'price': price,
    };
  }
}

class ChatMessage {
  final String id;
  final String userId;
  final String message;
  final String type; // 'text' or 'image'
  final String sender; // 'user' or 'ai'
  final DateTime timestamp;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    required this.sender,
    required this.timestamp,
    this.imageUrl,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      userId: json['user_id'],
      message: json['message'],
      type: json['type'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['image_url'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'message': message,
      'type': type,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'image_url': imageUrl,
      'metadata': metadata,
    };
  }
}