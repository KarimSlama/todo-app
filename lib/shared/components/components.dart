import 'package:audioplayers/audioplayers.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo/shared/cubit/cubit.dart';

Widget textForm({
  required TextInputType inputType,
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required FormFieldValidator<String>? validator,
  VoidCallback? onTap,
}) =>
    TextFormField(
      keyboardType: inputType,
      controller: controller,
      validator: validator,
      onTap: onTap,
      decoration: InputDecoration(
          label: Text(label),
          prefixIcon: Icon(icon),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(15.0))),
    );

Widget buildTaskItems(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${model['titles']}',
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  width: 60.0,
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          TasksCubit.getContext(context).updateData(
                            status: 'done',
                            id: model['id'],
                          );
                          AudioPlayer().play(AssetSource('audios/pop.mp3'));
                        },
                        icon: const Icon(Icons.check_circle_outline_outlined),
                        color: Colors.black38),
                    const SizedBox(
                      width: 12.0,
                    ),
                    IconButton(
                      onPressed: () {
                        TasksCubit.getContext(context).updateData(
                          status: 'archived',
                          id: model['id'],
                        );
                      },
                      icon: const Icon(Icons.archive_outlined),
                      color: Colors.black26,
                    ),
                    // ElevatedButton(
                    //   onPressed: () =>
                    //
                    //   child: Text(
                    //     'play',
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${model['time']}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(
                      width: 30.0,
                    ),
                    Text(
                      '${model['date']}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12.0,
                ),
                Text(
                  '${model['description']}',
                  style: const TextStyle(
                    fontSize: 15.0,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        TasksCubit.getContext(context).deleteData(
          id: model['id'],
        );
      },
    );

Widget tasksBuilder({required List<Map> tasks}) => ConditionalBuilder(
      condition: tasks.length > 0,
      builder: ((context) => ListView.separated(
            itemBuilder: (context, index) =>
                buildTaskItems(tasks[index], context),
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: double.infinity,
                height: 1.0,
                color: Colors.grey[200],
              ),
            ),
            itemCount: tasks.length,
          )),
      fallback: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_item.jpg',
            ),
            const Text('There is no item found',
                style: TextStyle(fontSize: 18.0)),
          ],
        ),
      ),
    );
