abstract class PersistableObject {
  Map<String, dynamic> toJson();
}

/// Example
// class PersistableObjectA implements PersistableObject {
//
//   @override
//   Map<String, dynamic> toJson() {}
//
//   static PersistableObjectA fromJson(Map<String, dynamic> json) {}
//
//   void example(PersistenceHelper helper) {
//     PersistableObject a = PersistableObjectA();
//     final json = a.toJson();
//     final object = helper.get<PersistableObjectA>(
//       'key',
//       PersistableObjectA.fromJson,
//     );
//   }
// }
