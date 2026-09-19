import '../../domain/entities/anomaly.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/insight.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../../transactions/data/datasources/local_transaction_data_source.dart';
import '../models/anomaly_model.dart';
import '../models/chat_message_model.dart';
import '../models/insight_model.dart';

/// Implementation of the [AIRepository] contract.
class AIRepositoryImpl implements AIRepository {
  final LocalTransactionDataSource? _transactionDataSource;

  AIRepositoryImpl([this._transactionDataSource]);

  @override
  Future<Map<String, double>> predictExpenses() async {
    final Map<String, double> predictions = {};
    if (_transactionDataSource != null) {
      final txs = await _transactionDataSource.getTransactions();
      for (final tx in txs) {
        predictions[tx.category] = (predictions[tx.category] ?? 0.0) + (tx.amount * 1.1);
      }
    }
    if (predictions.isEmpty) {
      predictions['Food'] = 350.0;
      predictions['Rent'] = 1200.0;
      predictions['Utilities'] = 150.0;
    }
    return predictions;
  }

  @override
  Future<List<Anomaly>> detectAnomalies() async {
    final List<Anomaly> anomalies = [];
    if (_transactionDataSource != null) {
      final txs = await _transactionDataSource.getTransactions();
      for (final tx in txs) {
        if (tx.amount > 1000.0) {
          anomalies.add(AnomalyModel(
            transactionId: tx.id,
            riskLevel: 'High',
            message: 'Transaction at ${tx.merchant} is unusually large (\$${tx.amount}).',
          ));
        }
      }
    }
    return anomalies;
  }

  @override
  Future<String> analyzeFinancialHealth() async {
    if (_transactionDataSource != null) {
      final txs = await _transactionDataSource.getTransactions();
      final total = txs.fold(0.0, (sum, tx) => sum + tx.amount);
      if (total > 5000.0) {
        return 'Your monthly spending is high (\$${total.toStringAsFixed(2)}). Consider setting stricter category budgets.';
      }
    }
    return 'Your financial health is stable. Keep tracking your expenses!';
  }

  @override
  Future<List<Insight>> generateInsights() async {
    return [
      const InsightModel(
        title: 'Subscription Alert',
        description: 'You have 3 active recurring subscriptions. Review if any are unused.',
        impactScore: 7.5,
      ),
      const InsightModel(
        title: 'Savings Potential',
        description: 'Dining out is 15% higher than last month. Preparing meals at home could save you ₹80.',
        impactScore: 8.2,
      ),
    ];
  }

  @override
  Future<ChatMessage> processChatQuery(String query) async {
    String reply = "I'm your BudgetBrain assistant. How can I help you manage your budget today?";
    final q = query.toLowerCase();
    if (q.contains('hello') || q.contains('hi')) {
      reply = 'Hello! I am BudgetBrain AI. Ask me about your budgets, transactions, or financial goals!';
    } else if (q.contains('budget')) {
      reply = 'You can set and monitor monthly budgets for different categories. I can also help you predict future expenses.';
    } else if (q.contains('transaction') || q.contains('spend')) {
      reply = 'I keep track of all your transaction history and will flag any abnormal or high-risk transactions.';
    }

    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: reply,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
