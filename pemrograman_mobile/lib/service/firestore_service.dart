import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/auth_service.dart';
import '../models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


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

class _HomePageState extends State<HomePage> {
  final FirestoreService firestore = FirestoreService();
  final AuthService authService = AuthService();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = authService.currentUser;
    print('HomePage init - Current User: ${currentUser?.email}');
  }

  Future<void> _signOut() async {
    try {
      print('Signing out...');
      await authService.signOut();
      print('Sign out successful');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await _signOut();
                // Navigate back to login after logout
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 8),
                    Text(currentUser?.email ?? 'User'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          print('HomePage auth state: ${authSnapshot.connectionState}');
          print('HomePage has user: ${authSnapshot.hasData}');
          
          // Jika user logout, redirect ke login
          if (!authSnapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print('User logged out, redirecting to login');
              Navigator.pushReplacementNamed(context, '/login');
            });
            return const Center(child: CircularProgressIndicator());
          }

          return _buildTaskContent();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildTaskContent() {
    return Column(
      children: [
        // Welcome Section
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentUser?.email ?? 'User',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        // Tasks Section
        Expanded(
          child: StreamBuilder<List<Task>>(
            stream: firestore.getTasks(),
            builder: (context, snapshot) {
              print('Tasks stream state: ${snapshot.connectionState}');
              print('Tasks has data: ${snapshot.hasData}');
              print('Tasks count: ${snapshot.data?.length ?? 0}');

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks yet!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first task',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final tasks = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone ? Colors.grey[500] : Colors.grey[800],
                          fontWeight: task.isDone ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                      subtitle: task.timestamp != null
                          ? Text(
                              'Created: ${_formatDate(task.timestamp!)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            )
                          : null,
                      value: task.isDone,
                      onChanged: (val) {
                        if (val != null) {
                          _toggleTaskWithErrorHandling(task.id, val);
                        }
                      },
                      secondary: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                        ),
                        onPressed: () => _showDeleteDialog(context, task),
                      ),
                      activeColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _toggleTaskWithErrorHandling(String taskId, bool isDone) async {
    try {
      await firestore.toggleDone(taskId, isDone);
    } catch (e) {
      print('Error toggling task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await firestore.deleteTask(task.id);
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error deleting task: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting task: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}