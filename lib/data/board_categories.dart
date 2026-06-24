import '../models/board_category.dart';

/// 보드 9 카테고리(3×3 그리드 순서).
///
///   Food   · Outfit · Color
///   Hobby  · Place  · Activity
///   Music  · Work   · Drink
const List<BoardCategory> kBoardCategories = <BoardCategory>[
  BoardCategory(id: 'food',     labelEn: 'Food',     row: 0, col: 0),
  BoardCategory(id: 'outfit',   labelEn: 'Outfit',   row: 0, col: 1),
  BoardCategory(id: 'color',    labelEn: 'Color',    row: 0, col: 2),
  BoardCategory(id: 'hobby',    labelEn: 'Hobby',    row: 1, col: 0),
  BoardCategory(id: 'place',    labelEn: 'Place',    row: 1, col: 1),
  BoardCategory(id: 'activity', labelEn: 'Activity', row: 1, col: 2),
  BoardCategory(id: 'music',    labelEn: 'Music',    row: 2, col: 0),
  BoardCategory(id: 'work',     labelEn: 'Work',     row: 2, col: 1),
  BoardCategory(id: 'drink',    labelEn: 'Drink',    row: 2, col: 2),
];
