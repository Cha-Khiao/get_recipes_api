import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe List',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const RecipeListPage(),
    );
  }
}

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});
  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Future<List<dynamic>> recipes;

  @override
  void initState() {
    super.initState();
    recipes = fetchRecipes();
  }

  Future<List<dynamic>> fetchRecipes() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/recipes'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['recipes'];
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        centerTitle: true,  // จัดกึ่งกลางหัวข้อ
      ),
      body: FutureBuilder<List<dynamic>>(
        future: recipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recipes found.'));
          }
          final recipes = snapshot.data!;
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Image.network(
                    recipe['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(recipe['name']),
                  subtitle: Text(
                    '⭐ ${recipe['rating']} | ${recipe['cuisine']} | ${recipe['difficulty']}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailPage(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Map recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name']),
        centerTitle: true,  // จัดกึ่งกลางหัวข้อ
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              recipe['image'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text('Cuisine: ${recipe['cuisine']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Difficulty: ${recipe['difficulty']}'),
            Text('Prep: ${recipe['prepTimeMinutes']} min | Cook: ${recipe['cookTimeMinutes']} min'),
            Text('Servings: ${recipe['servings']}'),
            Text('Calories/Serving: ${recipe['caloriesPerServing']}'),
            const SizedBox(height: 16),
            const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List<Widget>.from(recipe['ingredients'].map((i) => Text('• $i'))),
            const SizedBox(height: 16),
            const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List<Widget>.from(recipe['instructions'].map((i) => Text('- $i'))),
            const SizedBox(height: 16),
            Text('Tags: ${recipe['tags'].join(', ')}'),
            Text('Meal Type: ${recipe['mealType'].join(', ')}'),
            const SizedBox(height: 16),
            Text('Rating: ${recipe['rating']} (${recipe['reviewCount']} reviews)'),
          ],
        ),
      ),
    );
  }
}
