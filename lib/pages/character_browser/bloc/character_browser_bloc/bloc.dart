import 'package:bloc/bloc.dart';
import 'package:sweet/model/character/character.dart';
import 'package:sweet/repository/character_repository.dart';
import 'package:sweet/repository/item_repository.dart';

import 'events.dart';
import 'states.dart';

class CharacterBrowserBloc
    extends Bloc<CharacterBrowserEvent, CharacterBrowserState> {
  final CharacterRepository characterRepository;
  final ItemRepository itemRepository;

  CharacterBrowserBloc({
    required this.characterRepository,
    required this.itemRepository,
  }) : super(CharacterBrowserUninitialised()) {
    itemRepository.skillItems.then((value) => add(LoadCharacters()));
    on<CharacterBrowserEvent>((event, emit) => mapEventToState(event, emit));
  }

  // TODO: This is the old way, I should updated it
  Future<void> mapEventToState(
    CharacterBrowserEvent event,
    Emitter<CharacterBrowserState> emit,
  ) async {
    var skillItems = await itemRepository.skillItems;
    emit(CharacterBrowserLoading());
    if (event is AddNewCharacter) {
      if (event.baseLvl == 0 && event.advLvl == 0 && event.expLvl == 0) {
        await characterRepository
            .addCharacter(Character(name: event.characterName));
      } else {
        Character character = characterRepository.createAutoSkillCharacter(
            skills: itemRepository.fittingSkills.values,
            name: event.characterName,
            baseLvl: event.baseLvl,
            advLvl: event.advLvl,
            expLvl: event.expLvl
        );
        await characterRepository.addCharacter(character);
      }
    }
    if (event is CloneCharacter) {
      await characterRepository.addCharacter(
        event.character.copyWithName(
          event.characterName,
        ),
      );
    }

    if (event is DeleteCharacter) {
      await characterRepository.deleteCharacter(characterId: event.characterId);
    }

    if (event is ImportCharacter) {
      await characterRepository.addCharacter(event.character);
    }

    if (event is ReorderCharacter) {
      await characterRepository.moveCharacter(
        character: event.character,
        newIndex: event.newIndex,
      );
    }

    emit(CharacterBrowserLoaded(
      characterRepository.characters,
      skillItems.length,
    ));
  }
}
