part of 'in_experience_selection_bloc.dart';

class InExperienceSelectionState extends Equatable {
  const InExperienceSelectionState({
    this.drawerOption,
    this.selectedProps = const [],
    this.background = Background.space,
    this.character = Character.dash,
  });

  final DrawerOption? drawerOption;
  final List<Prop> selectedProps;
  final Background background;
  final Character character;

  @override
  List<Object?> get props => [
        drawerOption,
        selectedProps,
        background,
        character,
      ];

  InExperienceSelectionState copyWith({
    DrawerOption? drawerOption,
    List<Prop>? selectedProps,
    Background? background,
    Character? character,
  }) {
    return InExperienceSelectionState(
      drawerOption: drawerOption ?? this.drawerOption,
      selectedProps: selectedProps ?? this.selectedProps,
      background: background ?? this.background,
      character: character ?? this.character,
    );
  }
}