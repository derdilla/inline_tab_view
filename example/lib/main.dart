import 'package:flutter/material.dart';
import 'package:inline_tab_view/inline_tab_view.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      appBarTheme: AppBarTheme(color: Colors.teal)
    ),
    home: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('InlineTabView examples')),
    body: ListView(
      children: [
        Text('These examples include a TabBar, the classical TabBarView '
            '(constrained to a fixed height), and the InlineTabView.'),
        SwitchListTile(
          title: Text('Display classical TabBarView'),
          value: true, // TODO: implement
          onChanged: (v) {},
        ),
        Divider(),
        Text('Example with 2 colored boxes', style: Theme.of(context).textTheme.titleLarge,),
        FormSwitcher(
          subforms: [
            (Text('Box 1'), Container(height: 50, width: 100, color: Colors.red,)),
            (Text('Box 2'), Container(height: 200, width: 100, color: Colors.blue,)),
          ],
        ),

        Divider(),
        Text('Example with 3 widgets', style: Theme.of(context).textTheme.titleLarge,),
        FormSwitcher(
          subforms: [
            (Text('Widget 1'), Text(loremIpsum)),
            (Text('Widget 2'), Column(
              children: [
                TextField(),
                TextField(),
                TextField(),
              ],
            )),
            (Text('Widget 3'), Container(height: 200, width: 100, color: Colors.blue,)),
          ],
        ),

        Divider(),
        Text('Example with 20 colored boxes', style: Theme.of(context).textTheme.titleLarge,),
        FormSwitcher(
          subforms: [
            for (int i = 0; i < 20; i++)
              (Text('Box $i'), Container(height: 50.0 + 4.0 * i, width: 100.0,
                color: (i % 2 == 0) ? Colors.red : Colors.blue,)),
          ],
        ),
        SizedBox(height: 200,)
      ],
    ),
  );
}


class FormSwitcher extends StatefulWidget {
  const FormSwitcher({super.key, required this.subforms});

  final List<(Widget, Widget)> subforms;

  @override
  State<FormSwitcher> createState() => _FormSwitcherState();
}

class _FormSwitcherState extends State<FormSwitcher>
    with TickerProviderStateMixin {
  late final TabController controller;


  @override
  void initState() {
    super.initState();
    controller = TabController(length: widget.subforms.length, vsync: this);
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.subforms.isNotEmpty);
    if (widget.subforms.length == 1) {
      return widget.subforms[0].$2;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar.secondary(
          controller: controller,
          tabs: [
            for (final f in widget.subforms)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: f.$1,
              ),
          ],
        ),
        SizedBox(height: 10,),
        SizedBox(
          height: 210,
          child: TabBarView(
            controller: controller,
            children: [
              for (final f in widget.subforms)
                Align(alignment: Alignment.topCenter, child: f.$2),
            ],
          ),
        ),
        SizedBox(height: 8,),
        Container(width: 400, height: 4, color: Colors.blue,),
        SizedBox(height: 8,),
        InlineTabView(
          controller: controller,
          tabs: [
            for (final f in widget.subforms)
              f.$2,
          ],
        ),
      ],
    );
  }
}

const String loremIpsum = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem.';
