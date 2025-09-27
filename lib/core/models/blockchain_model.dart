class BlockchainTransaction {
  final String hash;
  final String batchId;
  final String fromAddress;
  final String toAddress;
  final String transactionType;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int blockNumber;
  final String status;
  final double gasUsed;
  final String? signature;

  BlockchainTransaction({
    required this.hash,
    required this.batchId,
    required this.fromAddress,
    required this.toAddress,
    required this.transactionType,
    required this.data,
    required this.timestamp,
    required this.blockNumber,
    required this.status,
    required this.gasUsed,
    this.signature,
  });

  factory BlockchainTransaction.fromJson(Map<String, dynamic> json) {
    return BlockchainTransaction(
      hash: json['hash'],
      batchId: json['batch_id'],
      fromAddress: json['from_address'],
      toAddress: json['to_address'],
      transactionType: json['transaction_type'],
      data: json['data'] ?? {},
      timestamp: DateTime.parse(json['timestamp']),
      blockNumber: json['block_number'],
      status: json['status'],
      gasUsed: json['gas_used']?.toDouble() ?? 0.0,
      signature: json['signature'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'batch_id': batchId,
      'from_address': fromAddress,
      'to_address': toAddress,
      'transaction_type': transactionType,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'block_number': blockNumber,
      'status': status,
      'gas_used': gasUsed,
      'signature': signature,
    };
  }
}

class TraceabilityRecord {
  final String batchId;
  final String productName;
  final List<TraceabilityStep> steps;
  final String currentStatus;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final String qrCode;

  TraceabilityRecord({
    required this.batchId,
    required this.productName,
    required this.steps,
    required this.currentStatus,
    required this.createdAt,
    required this.lastUpdated,
    required this.qrCode,
  });

  factory TraceabilityRecord.fromJson(Map<String, dynamic> json) {
    return TraceabilityRecord(
      batchId: json['batch_id'],
      productName: json['product_name'],
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((step) => TraceabilityStep.fromJson(step))
          .toList(),
      currentStatus: json['current_status'],
      createdAt: DateTime.parse(json['created_at']),
      lastUpdated: DateTime.parse(json['last_updated']),
      qrCode: json['qr_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'product_name': productName,
      'steps': steps.map((step) => step.toJson()).toList(),
      'current_status': currentStatus,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
      'qr_code': qrCode,
    };
  }
}

class TraceabilityStep {
  final int stepNumber;
  final String stakeholder;
  final String stakeholderName;
  final String action;
  final DateTime timestamp;
  final String location;
  final Map<String, dynamic> data;
  final String blockchainHash;
  final String status;

  TraceabilityStep({
    required this.stepNumber,
    required this.stakeholder,
    required this.stakeholderName,
    required this.action,
    required this.timestamp,
    required this.location,
    required this.data,
    required this.blockchainHash,
    required this.status,
  });

  factory TraceabilityStep.fromJson(Map<String, dynamic> json) {
    return TraceabilityStep(
      stepNumber: json['step_number'],
      stakeholder: json['stakeholder'],
      stakeholderName: json['stakeholder_name'],
      action: json['action'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
      data: json['data'] ?? {},
      blockchainHash: json['blockchain_hash'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'stakeholder': stakeholder,
      'stakeholder_name': stakeholderName,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'data': data,
      'blockchain_hash': blockchainHash,
      'status': status,
    };
  }
}

class SmartContract {
  final String address;
  final String name;
  final String abi;
  final Map<String, dynamic> functions;
  final DateTime deployedAt;
  final String network;

  SmartContract({
    required this.address,
    required this.name,
    required this.abi,
    required this.functions,
    required this.deployedAt,
    required this.network,
  });

  factory SmartContract.fromJson(Map<String, dynamic> json) {
    return SmartContract(
      address: json['address'],
      name: json['name'],
      abi: json['abi'],
      functions: json['functions'] ?? {},
      deployedAt: DateTime.parse(json['deployed_at']),
      network: json['network'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'name': name,
      'abi': abi,
      'functions': functions,
      'deployed_at': deployedAt.toIso8601String(),
      'network': network,
    };
  }
}

class Wallet {
  final String address;
  final String userId;
  final double balance;
  final String privateKey; // In production, this should be encrypted
  final String publicKey;
  final List<WalletTransaction> transactions;
  final DateTime createdAt;

  Wallet({
    required this.address,
    required this.userId,
    required this.balance,
    required this.privateKey,
    required this.publicKey,
    required this.transactions,
    required this.createdAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      address: json['address'],
      userId: json['user_id'],
      balance: json['balance']?.toDouble() ?? 0.0,
      privateKey: json['private_key'],
      publicKey: json['public_key'],
      transactions: (json['transactions'] as List<dynamic>? ?? [])
          .map((tx) => WalletTransaction.fromJson(tx))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'user_id': userId,
      'balance': balance,
      'private_key': privateKey,
      'public_key': publicKey,
      'transactions': transactions.map((tx) => tx.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class WalletTransaction {
  final String hash;
  final String type; // 'deposit', 'withdraw', 'payment', 'receive'
  final double amount;
  final DateTime timestamp;
  final String status;
  final String? description;

  WalletTransaction({
    required this.hash,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.status,
    this.description,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      hash: json['hash'],
      type: json['type'],
      amount: json['amount']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'type': type,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'description': description,
    };
  }
}