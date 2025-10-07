import 'package:flutter_test/flutter_test.dart';
import 'package:agrichain/core/services/blockchain_aadhaar_service.dart';

void main() {
  group('Wallet Assignment Tests', () {
    test('Should assign farmer wallet correctly', () {
      // Test farmer wallet assignment
      final wallet1 = BlockchainAadhaarService.assignWalletToUser(
        'user_123',
        'farmer',
      );
      final wallet2 = BlockchainAadhaarService.assignWalletToUser(
        'user_456',
        'farmer',
      );

      // Should assign valid Ethereum addresses
      expect(wallet1.startsWith('0x'), isTrue);
      expect(wallet1.length, equals(42));

      expect(wallet2.startsWith('0x'), isTrue);
      expect(wallet2.length, equals(42));

      print('✅ Farmer wallet 1: $wallet1');
      print('✅ Farmer wallet 2: $wallet2');
    });

    test('Should assign different wallets for different roles', () {
      final farmerWallet = BlockchainAadhaarService.assignWalletToUser(
        'user_123',
        'farmer',
      );
      final distributorWallet = BlockchainAadhaarService.assignWalletToUser(
        'user_123',
        'distributor',
      );
      final retailerWallet = BlockchainAadhaarService.assignWalletToUser(
        'user_123',
        'retailer',
      );

      // Different roles should get different wallets
      expect(farmerWallet, isNot(equals(distributorWallet)));
      expect(farmerWallet, isNot(equals(retailerWallet)));
      expect(distributorWallet, isNot(equals(retailerWallet)));

      print('✅ Farmer: $farmerWallet');
      print('✅ Distributor: $distributorWallet');
      print('✅ Retailer: $retailerWallet');
    });

    test('Should assign consistent wallets for same user', () {
      // Same user should always get the same wallet
      final wallet1 = BlockchainAadhaarService.assignWalletToUser(
        'user_789',
        'farmer',
      );
      final wallet2 = BlockchainAadhaarService.assignWalletToUser(
        'user_789',
        'farmer',
      );

      expect(wallet1, equals(wallet2));
      print('✅ Consistent wallet: $wallet1');
    });

    test('Should handle case insensitive roles', () {
      final wallet1 = BlockchainAadhaarService.assignWalletToUser(
        'user_999',
        'FARMER',
      );
      final wallet2 = BlockchainAadhaarService.assignWalletToUser(
        'user_999',
        'farmer',
      );
      final wallet3 = BlockchainAadhaarService.assignWalletToUser(
        'user_999',
        'Farmer',
      );

      // All should be the same regardless of case
      expect(wallet1, equals(wallet2));
      expect(wallet2, equals(wallet3));

      print('✅ Case insensitive: $wallet1');
    });

    test('Should throw error for invalid role', () {
      expect(
        () => BlockchainAadhaarService.assignWalletToUser(
          'user_000',
          'invalid_role',
        ),
        throwsA(isA<dynamic>()),
      );
      print('✅ Invalid role handling works');
    });
  });
}
