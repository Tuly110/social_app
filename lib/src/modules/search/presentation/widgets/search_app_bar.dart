import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../generated/colors.gen.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final TabController tabController;
  final VoidCallback onClearSearch;
  final VoidCallback onPerformSearch;
  final VoidCallback onBackPressed; 

  const SearchAppBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.tabController,
    required this.onClearSearch,
    required this.onPerformSearch,
    required this.onBackPressed, 
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);

  Widget _buildSearchField() {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorName.backgroundLight,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: ColorName.borderLight),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            color: ColorName.textGray,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: ColorName.textGray,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: ColorName.textBlack,
                fontSize: 16,
              ),
              onSubmitted: (_) => onPerformSearch(),
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.xmark,
                size: 16,
                color: ColorName.textGray,
              ),
              onPressed: onClearSearch,
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorName.backgroundWhite,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: onBackPressed,
      ),
      title: _buildSearchField(),
      bottom: TabBar(
        controller: tabController,
        indicatorColor: ColorName.navBackground,
        labelColor: ColorName.textBlack,
        unselectedLabelColor: ColorName.textGray,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Top'),
          Tab(text: 'Latest'),
          Tab(text: 'People'),
          Tab(text: 'Media'),
        ],
      ),
    );
  }
}