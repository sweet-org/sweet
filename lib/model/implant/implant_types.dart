
import 'package:sweet/model/ship/eve_echoes_attribute.dart';

enum ImplantBuffType {
  clusterBombing,
}

extension ImplantBuffExtraAttrs on ImplantBuffType {
  Map<EveEchoesAttribute, List<EveEchoesAttribute>> getExtraAttrs(ImplantBuffType type) {
    switch (type) {
      case ImplantBuffType.clusterBombing:
        return {
          EveEchoesAttribute.implantCBDamageModX: [EveEchoesAttribute.implantCBDamageModX]
        };
    }
  }
}
