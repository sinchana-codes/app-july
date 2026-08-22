import 'package:flutter/material.dart';

void main() {
  runApp(const MyPortfolioApp());
}

class MyPortfolioApp extends StatelessWidget {
  const MyPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Portfolio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PortfolioHomePage(),
    );
  }
}

class PortfolioHomePage extends StatelessWidget {
  const PortfolioHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 30),

            // Profile Picture
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 70,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 15),

            // Name
            const Text(
              'Sinchana B',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            // Profession
            const Text(
              'flutter developer and Computer Science Student',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            // About Section
            buildCard(
              icon: Icons.person_outline,
              title: 'About Me',
              subtitle: 'Learn more about me',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const
                    AboutMePage(),
                  ) 
                );
              },
            ),

            buildCard(
             icon: Icons.school,
             title: 'Education',
             subtitle: 'My educational background',
             onTap: () {
              Navigator.push(
               context,
               MaterialPageRoute(
                builder: (context) => const EducationPage(),
              ),
             );
            },
           ),

            buildCard(
              icon: Icons.code,
              title: 'Skills',
              subtitle: 'My technical skills',
              onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                 builder: (context) => const SkillsPage(),
               ),
             );
           },
          ),         
            

            buildCard(
              icon: Icons.folder,
              title: 'Projects',
              subtitle: 'My projects and work',
              onTap: () {
               Navigator.push(
                context,
               MaterialPageRoute(
                builder: (context) => const ProjectsPage(),
              ),
             );
           },
          ),
            

            buildCard(
              icon: Icons.contact_mail,
              title: 'Contact Me',
              subtitle: 'Get in touch with me',
              onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                 builder: (context) => const ContactMePage(),
                ),
              );
            },
          ),
          

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue,
          size: 30,
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(subtitle),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: onTap,
      ),
    );
  }
}

class AboutMePage extends StatelessWidget{
  const AboutMePage({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('About me'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child:Text(
          'Hello! I am a computer science student and aspiring flutter developer.'
          'I am interested in mobile app development and learning new technologies.',
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Education',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Bachelor of Computer Science',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Acharya institute of technology',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Skills',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Text(
              '• Flutter',
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 10),

            Text(
              '• Dart',
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 10),

            Text(
              '• Python',
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 10),

            Text(
              '• C programming',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'My Projects',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('Personal Portfolio App'),
                subtitle: const Text(
                  'A Flutter app that displays my profile, education, skills, and projects.',
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Student Management App'),
                subtitle: const Text(
                  'An application for managing student information.',
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.web),
                title: const Text('Personal Website'),
                subtitle: const Text(
                  'A website created to showcase my skills and projects.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactMePage extends StatelessWidget {
  const ContactMePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Me'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get In Touch',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 25),

            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text('sinchanab62@gmail.com'),
            ),

            SizedBox(height: 10),

            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text('+91 93534 XXXXX'),
            ),

            SizedBox(height: 10),

            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Location'),
              subtitle: Text('banglore, India'),
            ),
          ],
        ),
      ),
    );
  }
}