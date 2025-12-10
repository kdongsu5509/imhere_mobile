import 'package:iamhere/common/database/local_database_service.dart';
import 'package:iamhere/contact/repository/contact_entity.dart';
import 'package:iamhere/contact/repository/contact_repository.dart';

class ContactLocalRepository implements ContactRepository {
  final LocalDatabaseService _database = LocalDatabaseService.instance;

  @override
  Future<List<ContactEntity>> findAll() async {
    return await _database.findAllContacts();
  }

  @override
  Future<ContactEntity> save(ContactEntity entity) async {
    return await _database.saveContact(entity);
  }

  @override
  Future<void> delete(int id) async {
    await _database.deleteContact(id);
  }
}
