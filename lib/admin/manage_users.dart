import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
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
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text("All Customers"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ================= SEARCH =================
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search user by name or email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                  page = 0;
                });
              },
            ),

            const SizedBox(height: 15),

            // ================= USER LIST =================
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

                  final docs = snapshot.data!.docs;

                  // Convert safely
                  List<Map<String, dynamic>> allUsers = docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    data["__id"] = doc.id;
                    return data;
                  }).toList();

                  // Sort by name
                  allUsers.sort((a, b) {
                    final aName = (a["name"] ?? "").toString();
                    final bName = (b["name"] ?? "").toString();
                    return aName.compareTo(bName);
                  });

                  // Search filter
                  final filtered = allUsers.where((u) {
                    final name =
                        (u["name"] ?? "").toString().toLowerCase();
                    final email =
                        (u["email"] ?? "").toString().toLowerCase();
                    return name.contains(searchQuery) ||
                        email.contains(searchQuery);
                  }).toList();

                  final total = filtered.length;
                  final start = page * limit;
                  final end =
                      (start + limit > total) ? total : start + limit;

                  final users = filtered.sublist(
                    start,
                    end < start ? start : end,
                  );

                  return Column(
                    children: [
                      Expanded(
                        child: users.isEmpty
                            ? const Center(child: Text("No users found"))
                            : ListView.builder(
                                itemCount: users.length,
                                itemBuilder: (_, index) {
                                  final u = users[index];

                                  final bool disabled =
                                      u.containsKey("disabled")
                                          ? u["disabled"] == true
                                          : false;

                                  final Timestamp? ts =
                                      u.containsKey("createdAt")
                                          ? u["createdAt"]
                                          : null;

                                  final DateTime? createdAt =
                                      ts?.toDate();

                                  final String? profilePic =
                                      u.containsKey("profilePic")
                                          ? u["profilePic"]
                                          : null;

                                  return Card(
                                    margin:
                                        const EdgeInsets.only(bottom: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      // ================= PROFILE =================
                                      leading: CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            Colors.grey.shade200,
                                        backgroundImage:
                                            profilePic != null &&
                                                    profilePic.isNotEmpty
                                                ? NetworkImage(profilePic)
                                                : null,
                                        child: profilePic == null ||
                                                profilePic.isEmpty
                                            ? Icon(
                                                disabled
                                                    ? Icons.block
                                                    : Icons.person,
                                                color:
                                                    Colors.grey.shade700,
                                              )
                                            : null,
                                      ),

                                      // ================= NAME + STATUS =================
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              u["name"] ?? "Unknown",
                                              style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (disabled)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                              ),
                                              child: const Text(
                                                "Disabled",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      // ================= EMAIL + DATE =================
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
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // ================= ACTION =================
                                      trailing: PopupMenuButton<String>(
                                        itemBuilder: (_) => [
                                          PopupMenuItem(
                                            value: disabled
                                                ? "enable"
                                                : "disable",
                                            child: Text(
                                              disabled
                                                  ? "Enable User"
                                                  : "Disable User",
                                            ),
                                          ),
                                        ],
                                        onSelected: (val) async {
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(u["__id"])
                                              .update({
                                            "disabled":
                                                val == "disable"
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // ================= PAGINATION =================
                      if (total > limit)
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: page > 0
                                  ? () =>
                                      setState(() => page--)
                                  : null,
                              child: const Text("Previous"),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: end < total
                                  ? () =>
                                      setState(() => page++)
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
