import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  String searchQuery = "";
  int page = 0;
  final int limit = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Customers"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search user by name or email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.trim());
              },
            ),

            const SizedBox(height: 15),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("role", isEqualTo: "customer")
                    .snapshots(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allUsers = snapshot.data!.docs;

                  /// SORT LOCALLY
                  allUsers.sort((a, b) =>
                      (a["name"] ?? "").toString().compareTo(
                            (b["name"] ?? "").toString(),
                          ));

                  /// APPLY SEARCH
                  final filtered = allUsers.where((u) {
                    final name = (u["name"] ?? "").toLowerCase();
                    final email = (u["email"] ?? "").toLowerCase();
                    final q = searchQuery.toLowerCase();
                    return name.contains(q) || email.contains(q);
                  }).toList();

                  /// PAGINATION
                  final total = filtered.length;
                  final start = page * limit;
                  final end = (start + limit > total) ? total : start + limit;

                  final users = filtered.sublist(start, end);

                  return Column(
                    children: [
                      Expanded(
                        child: users.isEmpty
                            ? const Center(child: Text("No users found"))
                            : ListView.builder(
                                itemCount: users.length,
                                itemBuilder: (_, index) {
                                  final u = users[index];
                                  final Timestamp? ts = u["createdAt"];
                                  final createdAt = ts?.toDate();

                                  final bool disabled = u["disabled"] == true;

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            disabled ? Colors.grey : Colors.blue,
                                        child: Icon(
                                          disabled
                                              ? Icons.block
                                              : Icons.person,
                                          color: Colors.white,
                                        ),
                                      ),

                                      title: Row(
                                        children: [
                                          Text(
                                            u["name"] ?? "Unknown",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),

                                          if (disabled)
                                            Container(
                                              margin: const EdgeInsets.only(left: 8),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                "Disabled",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                        ],
                                      ),

                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(u["email"] ?? ""),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Joined: ${createdAt != null ? createdAt.toString().substring(0, 10) : "N/A"}",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),

                                      trailing: PopupMenuButton(
                                        itemBuilder: (_) => [
                                          PopupMenuItem(
                                            value: disabled ? "enable" : "disable",
                                            child: Text(
                                              disabled
                                                  ? "Enable User"
                                                  : "Disable User",
                                            ),
                                          ),
                                        ],

                                        /// ACTIONS
                                        onSelected: (val) async {
                                          if (val == "disable") {
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(u.id)
                                                .update({"disabled": true});
                                          }

                                          if (val == "enable") {
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(u.id)
                                                .update({"disabled": false});
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      /// PAGINATION BUTTONS
                      if (total > limit)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  page > 0 ? () => setState(() => page--) : null,
                              child: const Text("Previous"),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: end < total
                                  ? () => setState(() => page++)
                                  : null,
                              child: const Text("Next"),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
