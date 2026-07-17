import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/news_category.dart';

/// Static category catalog. In a real API this would come from a
/// `/categories` endpoint — kept here as the single source of truth so
/// swapping to remote data later means implementing one fetch method.
const List<NewsCategory> kMockCategories = [
  NewsCategory(
    id: 'sports',
    name: 'Sports',
    icon: Icons.sports_soccer_rounded,
    color: AppColors.sports,
  ),
  NewsCategory(
    id: 'politics',
    name: 'Politics',
    icon: Icons.gavel_rounded,
    color: AppColors.politics,
  ),
  NewsCategory(
    id: 'health',
    name: 'Health',
    icon: Icons.favorite_rounded,
    color: AppColors.health,
  ),
  NewsCategory(
    id: 'business',
    name: 'Business',
    icon: Icons.trending_up_rounded,
    color: AppColors.business,
  ),
  NewsCategory(
    id: 'environment',
    name: 'Environment',
    icon: Icons.public_rounded,
    color: AppColors.environment,
  ),
  NewsCategory(
    id: 'science',
    name: 'Science',
    icon: Icons.science_rounded,
    color: AppColors.science,
  ),
  NewsCategory(
    id: 'technology',
    name: 'Technology',
    icon: Icons.memory_rounded,
    color: AppColors.technology,
  ),
  NewsCategory(
    id: 'entertainment',
    name: 'Entertainment',
    icon: Icons.theaters_rounded,
    color: AppColors.entertainment,
  ),
];

NewsCategory categoryById(String id) =>
    kMockCategories.firstWhere((c) => c.id == id, orElse: () => kMockCategories.first);
