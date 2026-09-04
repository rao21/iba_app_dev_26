import 'package:flutter/material.dart';

import '../widgets/demo_card.dart';

/// Leaf widgets: the ones that actually draw something on screen.
class BasicsPage extends StatelessWidget {
  const BasicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        DemoCard(
          title: 'Text',
          note: 'A string. Styling goes through TextStyle or the theme.',
          code: '''
Text(
  'Roll No. 26451',
  style: Theme.of(context).textTheme.titleLarge,
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Roll No. 26451',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'A long line is clipped with an ellipsis when it runs out of room.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const DemoCard(
          title: 'Icon',
          note: 'Over a thousand Material icons ship with Flutter.',
          code: "Icon(Icons.school, size: 32, color: Colors.indigo)",
          child: Wrap(
            spacing: 20,
            children: [
              Icon(Icons.school, size: 32),
              Icon(Icons.menu_book, size: 32),
              Icon(Icons.favorite, size: 32, color: Colors.redAccent),
              Icon(Icons.wifi_off, size: 32),
            ],
          ),
        ),
        const DemoCard(
          title: 'CircleAvatar',
          note: 'A round photo, or initials when there is no photo.',
          code: '''
CircleAvatar(
  radius: 28,
  child: Text('RN'),
)''',
          child: Row(
            children: [
              CircleAvatar(radius: 28, child: Text('RN')),
              SizedBox(width: 16),
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'Card + ListTile',
          note: 'The fastest way to a row that already looks right.',
          code: '''
Card(
  child: ListTile(
    leading: CircleAvatar(child: Text('1')),
    title: Text('App Development'),
    subtitle: Text('3 credit hours'),
    trailing: Icon(Icons.chevron_right),
    onTap: () {},
  ),
)''',
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const CircleAvatar(child: Text('1')),
              title: const Text('App Development'),
              subtitle: const Text('3 credit hours'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ),
        const DemoCard(
          title: 'Chip',
          note: 'A compact tag. Handy for filters and labels.',
          code: "Chip(label: Text('Semester 5'))",
          child: Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('Semester 5')),
              Chip(label: Text('BSCS')),
              Chip(avatar: Icon(Icons.check, size: 18), label: Text('Enrolled')),
            ],
          ),
        ),
        const DemoCard(
          title: 'Image.network',
          note: 'Always give a loading and an error path — networks fail.',
          code: '''
Image.network(
  'https://picsum.photos/400/200',
  height: 120,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stack) => const Icon(Icons.broken_image),
)''',
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: Image(
              image: NetworkImage('https://picsum.photos/400/200'),
              fit: BoxFit.cover,
              errorBuilder: _imageError,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _imageError(BuildContext context, Object error, StackTrace? stack) {
  return const ColoredBox(
    color: Color(0x11000000),
    child: Center(child: Icon(Icons.broken_image_outlined)),
  );
}
