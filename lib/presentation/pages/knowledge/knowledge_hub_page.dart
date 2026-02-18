// knowledge_hub_page.dart
// Redesigned Knowledge Hub with integrated Tips, Community, and Agriculture News
// Farmer-first design: Simple, warm, trustworthy, and community-oriented

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ==================== DATA MODELS ====================

enum KnowledgeTab { tips, community, news }

enum TipCategory { all, videos, schemes, seasonal, success }

enum NewsCategory { govt, weather, market, advisory }

class TipModel {
  final String id;
  final String category;
  final String title;
  final String description;
  final String iconEmoji;
  final Color backgroundColor;
  final String? categoryLabel;

  TipModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.backgroundColor,
    this.categoryLabel,
  });
}

class CommunityQuestion {
  final String id;
  final String cropName;
  final String cropEmoji;
  final String location;
  final String question;
  final int helpfulCount;
  final bool isExpertAnswered;

  CommunityQuestion({
    required this.id,
    required this.cropName,
    required this.cropEmoji,
    required this.location,
    required this.question,
    required this.helpfulCount,
    this.isExpertAnswered = false,
  });
}

class AgriNews {
  final String id;
  final String headline;
  final String category;
  final IconData categoryIcon;
  final Color categoryColor;

  AgriNews({
    required this.id,
    required this.headline,
    required this.category,
    required this.categoryIcon,
    required this.categoryColor,
  });
}

// ==================== DUMMY DATA ====================

class KnowledgeHubData {
  static final List<TipModel> tips = [
    TipModel(
      id: '1',
      category: 'Water Management',
      title: 'Smart Irrigation Techniques',
      description: 'Save water and improve crop yield with drip irrigation',
      iconEmoji: '💧',
      backgroundColor: const Color(0xFFE3F2FD),
      categoryLabel: 'Water Management',
    ),
    TipModel(
      id: '2',
      category: 'Pest Management',
      title: 'Natural Pest Control',
      description: 'Use neem oil and companion planting to control pests',
      iconEmoji: '🐛',
      backgroundColor: const Color(0xFFFCE4EC),
      categoryLabel: 'Pest Management',
    ),
    TipModel(
      id: '3',
      category: 'Soil Health',
      title: 'Organic Fertilizers',
      description: 'Make compost at home to enrich your soil naturally',
      iconEmoji: '🌱',
      backgroundColor: const Color(0xFFF1F8E9),
      categoryLabel: 'Soil Health',
    ),
    TipModel(
      id: '4',
      category: 'Planning',
      title: 'Weather-Based Planning',
      description: 'Schedule farm activities based on weather forecast',
      iconEmoji: '☁️',
      backgroundColor: const Color(0xFFE1F5FE),
      categoryLabel: 'Planning',
    ),
    TipModel(
      id: '5',
      category: 'Success Story',
      title: 'Organic Farming Success',
      description: 'How farmers increased income by 40% with organic methods',
      iconEmoji: '🏆',
      backgroundColor: const Color(0xFFFFF3E0),
      categoryLabel: 'Success Stories',
    ),
  ];

  static final List<CommunityQuestion> questions = [
    CommunityQuestion(
      id: '1',
      cropName: 'Tomato',
      cropEmoji: '🍅',
      location: 'Telangana',
      question: 'Leaves turning yellow after rain',
      helpfulCount: 12,
      isExpertAnswered: true,
    ),
    CommunityQuestion(
      id: '2',
      cropName: 'Wheat',
      cropEmoji: '🌾',
      location: 'Punjab',
      question: 'Best time for second irrigation?',
      helpfulCount: 8,
      isExpertAnswered: false,
    ),
    CommunityQuestion(
      id: '3',
      cropName: 'Cotton',
      cropEmoji: '🌿',
      location: 'Gujarat',
      question: 'White flies attacking my crop',
      helpfulCount: 15,
      isExpertAnswered: true,
    ),
    CommunityQuestion(
      id: '4',
      cropName: 'Rice',
      cropEmoji: '🌾',
      location: 'Andhra Pradesh',
      question: 'Stem borer prevention methods',
      helpfulCount: 6,
      isExpertAnswered: false,
    ),
  ];

  static final List<AgriNews> news = [
    AgriNews(
      id: '1',
      headline: 'Onion MSP increased by ₹200 per quintal',
      category: 'Market',
      categoryIcon: Icons.trending_up,
      categoryColor: const Color(0xFF2E7D32),
    ),
    AgriNews(
      id: '2',
      headline: 'New PM-Kisan installment releasing on Feb 20',
      category: 'Govt',
      categoryIcon: Icons.account_balance,
      categoryColor: const Color(0xFF1565C0),
    ),
    AgriNews(
      id: '3',
      headline: 'Heavy rainfall expected in coastal regions',
      category: 'Weather',
      categoryIcon: Icons.cloud,
      categoryColor: const Color(0xFF0277BD),
    ),
    AgriNews(
      id: '4',
      headline: 'Apply organic pesticides for cotton crops now',
      category: 'Advisory',
      categoryIcon: Icons.info_outline,
      categoryColor: const Color(0xFFE65100),
    ),
  ];
}

// ==================== MAIN KNOWLEDGE HUB PAGE ====================

class KnowledgeHubPage extends StatefulWidget {
  const KnowledgeHubPage({super.key});

  @override
  State<KnowledgeHubPage> createState() => _KnowledgeHubPageState();
}

class _KnowledgeHubPageState extends State<KnowledgeHubPage>
    with TickerProviderStateMixin {
  KnowledgeTab _selectedTab = KnowledgeTab.tips;
  TipCategory _selectedTipFilter = TipCategory.all;
  NewsCategory? _selectedNewsFilter;

  late AnimationController _tabAnimController;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Tab switch animation
    _tabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Breathing animation for "Ask Question" button
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tabAnimController.dispose();
    _breathingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _switchTab(KnowledgeTab tab) {
    if (_selectedTab != tab) {
      setState(() => _selectedTab = tab);
      _tabAnimController.forward(from: 0);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildAppBar(context),
          _buildSearchBar(),
          _buildTabSwitcher(),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  // ==================== APP BAR ====================
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2E7D32), const Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              'Knowledge Hub',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
            ),
          ),
          // Language switch button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.language,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SEARCH BAR WITH VOICE ====================
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Search tips, ask questions, or find updates…',
                hintStyle: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Voice input button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Voice input logic
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.mic,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PRIMARY TAB SWITCHER ====================
  Widget _buildTabSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton(
            label: '🌱 Tips',
            tab: KnowledgeTab.tips,
            isSelected: _selectedTab == KnowledgeTab.tips,
          ),
          _buildTabButton(
            label: '🤝 Community',
            tab: KnowledgeTab.community,
            isSelected: _selectedTab == KnowledgeTab.community,
          ),
          _buildTabButton(
            label: '📰 News',
            tab: KnowledgeTab.news,
            isSelected: _selectedTab == KnowledgeTab.news,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required KnowledgeTab tab,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF616161),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== TAB CONTENT ====================
  Widget _buildTabContent() {
    return FadeTransition(
      opacity: _tabAnimController.drive(
        CurveTween(curve: Curves.easeIn),
      ),
      child: SlideTransition(
        position: _tabAnimController.drive(
          Tween<Offset>(
            begin: const Offset(0.02, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: _getTabContent(),
      ),
    );
  }

  Widget _getTabContent() {
    switch (_selectedTab) {
      case KnowledgeTab.tips:
        return _buildTipsTab();
      case KnowledgeTab.community:
        return _buildCommunityTab();
      case KnowledgeTab.news:
        return _buildNewsTab();
    }
  }

  // ==================== TIPS TAB ====================
  Widget _buildTipsTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildTipFilters(),
        const SizedBox(height: 12),
        Expanded(
          child: _buildTipsList(),
        ),
      ],
    );
  }

  Widget _buildTipFilters() {
    final filters = [
      {'label': 'All', 'value': TipCategory.all},
      {'label': 'Videos', 'value': TipCategory.videos},
      {'label': 'Schemes', 'value': TipCategory.schemes},
      {'label': 'Seasonal', 'value': TipCategory.seasonal},
      {'label': 'Success', 'value': TipCategory.success},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedTipFilter == filter['value'];
          return Padding(
            padding: EdgeInsets.only(right: index < filters.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                setState(
                    () => _selectedTipFilter = filter['value'] as TipCategory);
                HapticFeedback.selectionClick();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  filter['label'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF757575),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: KnowledgeHubData.tips.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: index < KnowledgeHubData.tips.length - 1 ? 12 : 20),
          child: _buildTipCard(KnowledgeHubData.tips[index]),
        );
      },
    );
  }

  Widget _buildTipCard(TipModel tip) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to tip details
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: tip.backgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                tip.iconEmoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category label
                  if (tip.categoryLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tip.categoryLabel!,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    tip.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Action buttons
                  Row(
                    children: [
                      _buildActionChip(
                        icon: Icons.volume_up,
                        label: 'Listen',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // Text-to-speech
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionChip(
                        icon: Icons.bookmark_border,
                        label: 'Save',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // Save tip
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Arrow
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9E9E9E),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== COMMUNITY TAB ====================
  Widget _buildCommunityTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildAskQuestionButton(),
        const SizedBox(height: 16),
        Expanded(
          child: _buildCommunityQuestionsList(),
        ),
      ],
    );
  }

  Widget _buildAskQuestionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ScaleTransition(
        scale: _breathingAnimation,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            // Open ask question screen
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.mic, color: Colors.white, size: 26),
                    SizedBox(width: 10),
                    Text(
                      'Ask a Question',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Speak or type your farming problem',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityQuestionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: KnowledgeHubData.questions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < KnowledgeHubData.questions.length - 1 ? 12 : 20,
          ),
          child: _buildCommunityQuestionCard(KnowledgeHubData.questions[index]),
        );
      },
    );
  }

  Widget _buildCommunityQuestionCard(CommunityQuestion question) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to question detail screen
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: question.isExpertAnswered
                ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Crop icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                question.cropEmoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop name + Location
                  Row(
                    children: [
                      Text(
                        question.cropName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '•',
                        style: TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        question.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (question.isExpertAnswered) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '✓ Expert',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Question
                  Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Action buttons
                  Row(
                    children: [
                      _buildActionChip(
                        icon: Icons.volume_up,
                        label: 'Listen',
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionChip(
                        icon: Icons.thumb_up_outlined,
                        label: 'Helpful (${question.helpfulCount})',
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== NEWS TAB ====================
  Widget _buildNewsTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildNewsFilters(),
        const SizedBox(height: 12),
        Expanded(
          child: _buildNewsList(),
        ),
      ],
    );
  }

  Widget _buildNewsFilters() {
    final filters = [
      {'label': 'Govt', 'value': NewsCategory.govt},
      {'label': 'Weather', 'value': NewsCategory.weather},
      {'label': 'Market', 'value': NewsCategory.market},
      {'label': 'Advisory', 'value': NewsCategory.advisory},
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedNewsFilter == filter['value'];
          return Padding(
            padding: EdgeInsets.only(right: index < filters.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedNewsFilter =
                      isSelected ? null : filter['value'] as NewsCategory;
                });
                HapticFeedback.selectionClick();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  filter['label'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF757575),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: math.min(KnowledgeHubData.news.length, 5), // Max 5 news items
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                index < math.min(KnowledgeHubData.news.length, 5) - 1 ? 12 : 20,
          ),
          child: _buildNewsCard(KnowledgeHubData.news[index]),
        );
      },
    );
  }

  Widget _buildNewsCard(AgriNews news) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to news detail
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: news.categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                news.categoryIcon,
                color: news.categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline
                  Text(
                    news.headline,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Action buttons
                  Row(
                    children: [
                      _buildActionChip(
                        icon: Icons.volume_up,
                        label: 'Listen',
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionChip(
                        icon: Icons.article_outlined,
                        label: 'Read',
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Arrow
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9E9E9E),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== REUSABLE ACTION CHIP ====================
  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF616161)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF616161),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
