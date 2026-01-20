import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user tasks collection reference dengan error handling
  CollectionReference _userTasksRef() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(user.uid).collection('tasks');
  }

  // Add task
  Future<void> addTask(Task task) async {
    try {
      final docRef = _userTasksRef().doc();
      final taskWithId = task.copyWith(id: docRef.id);
      await docRef.set(taskWithId.toMap());
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  // Get tasks stream dengan handling user null
  Stream<List<Task>> getTasks() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Return empty stream jika user null
        return Stream.value([]);
      }
      
      return _userTasksRef()
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    } catch (e) {
      print('Error getting tasks stream: $e');
      return Stream.value([]);
    }
  }

  // Toggle task done status
  Future<void> toggleDone(String taskId, bool isDone) async {
    try {
      await _userTasksRef().doc(taskId).update({'isDone': isDone});
    } catch (e) {
      print('Error toggling task: $e');
      rethrow;
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _userTasksRef().doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // Update task
  Future<void> updateTask(String taskId, String newTitle) async {
    try {
      await _userTasksRef().doc(taskId).update({
        'title': newTitle,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }
}
