import 'package:sweet/database/entities/item.dart';
import 'package:sweet/model/items/eve_echoes_categories.dart';

extension ItemMeta on Item {
  bool get isRigIntegrator {
    return kRigIntegrators.map((e) => e.groupId).contains(groupId);
  }
}
