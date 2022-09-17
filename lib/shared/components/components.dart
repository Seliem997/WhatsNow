
import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';

import '../cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  double radius = 3,
  Color backgroundButton = Colors.blue,
  bool isUpperCase = true,
  required VoidCallback function,
  required String textData,
}) {
  return Container(
    width: width,
    decoration: BoxDecoration(
      color: backgroundButton,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: MaterialButton(
      onPressed: function,
      child: Text(
        isUpperCase ? textData.toUpperCase() : textData,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  required String label,
  required IconData prefixIcn,
  required FormFieldValidator validate,
  Function(dynamic)? onSubm,
  Function(dynamic)? onChang,
  GestureTapCallback? tap,
  bool isPassword= false,
  IconData? suffixIcn,
  VoidCallback? suffixPressed,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      onFieldSubmitted: onSubm,
      onChanged: onChang,
      onTap: tap,
      validator: validate,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefixIcn,
        ),
        suffixIcon: suffixIcn!=null ? IconButton(
          onPressed: suffixPressed,
          icon: Icon(
            suffixIcn,
          ),
        ) : null ,
        border: const OutlineInputBorder(),
      ),
    );

Widget buildTaskItem(Map model, context){
  return Dismissible(
    key: Key(model['id'].toString()),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            child: Text(
              model['time'],
            ),
          ),
          const SizedBox(width: 20,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${model['title']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${model['date']}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15,),
          IconButton(onPressed: (){
            AppCubit.get(context).updateData(status:'done', id: model['id']);
          }, icon: const Icon(
              Icons.check_box,
            color: Colors.green,
          )),
          const SizedBox(width: 15,),
          IconButton(onPressed: (){
            AppCubit.get(context).updateData(status:'archived', id: model['id']);
          }, icon: const Icon(
              Icons.archive,
            color: Colors.black45,
          )),
        ],
      ),
    ),
    onDismissed: (direction){
      AppCubit.get(context).deleteData(id: model['id']);
    },
  );
}

Widget tasksBuilder({required List<Map> tasks,context}){
  return Conditional.single(
    context: context,
    conditionBuilder: (BuildContext context) => tasks.length>0 ,
    widgetBuilder: (BuildContext context) {
      return ListView.separated(itemBuilder: (context,index)=> buildTaskItem(tasks[index],context),
        separatorBuilder: (context,index)=> Padding(
          padding: const EdgeInsetsDirectional.only(start: 10),
          child: Container(
            width: double.infinity,
            height: 1.0,
            color: Colors.grey[300],
          ),
        ),
        itemCount: tasks.length,
      );
    },
    fallbackBuilder: (BuildContext context) =>Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.menu,
            color: Colors.grey,
            size: 100,
          ),
          SizedBox(height: 15,),
          Text(
            'No Tasks Yet, Please Add Some Tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          )
        ],
      ),
    ),

  );
}