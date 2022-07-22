import 'package:servicestack/servicestack.dart';

import 'dart:convert';
class XMLJSON implements IConvertible{
  int checklist_id;
  String status;
  String failed_reason;


  XMLJSON(
      {this.checklist_id,
        this.status,
        this.failed_reason,

      });

  XMLJSON.fromJson(Map<String, dynamic> json)
  {
    fromMap(json);
  }

  fromMap(Map<String, dynamic> json) {
    checklist_id = json['checklist_id'];
    status = json['status'];
    failed_reason = json['failed_reason'];
    return this;
  }

  Map<String, dynamic> toJson() =>{
    'checklist_id' : checklist_id,
    'status' :status,
    'failed_reason' :failed_reason
  };

  @override
  TypeContext context;

}