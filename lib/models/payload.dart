
import 'dart:convert';

PayLoad payloadFromJson(String str) => PayLoad.fromJson(json.decode(str));

String payloadToJson(PayLoad data) => json.encode(data.toJson());

class PayLoad {
  int status;
  List<Data> data;
  Meta mMeta;

  PayLoad({this.status, this.data, this.mMeta});

  PayLoad.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
    mMeta = json['__meta'] != null ? new Meta.fromJson(json['__meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    if (this.mMeta != null) {
      data['__meta'] = this.mMeta.toJson();
    }
    return data;
  }
}

class Data {
  int id;
  int customerId;
  int driverId;
  String jobSystemId;
  int productId;
  String jobDate;
  String jobQty;
  String jobVat;
  String jobAmount;
  String jobRemarks;
  int jobStatus;
  Customer customer;
  Product product;

  Data(
      {this.id,
        this.customerId,
        this.driverId,
        this.jobSystemId,
        this.productId,
        this.jobDate,
        this.jobQty,
        this.jobVat,
        this.jobAmount,
        this.jobRemarks,
        this.jobStatus,
        this.customer,
        this.product});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    driverId = json['driver_id'];
    jobSystemId = json['job_system_id'];
    productId = json['product_id'];
    jobDate = json['job_date'];
    jobQty = json['job_qty'];
    jobVat = json['job_vat'];
    jobAmount = json['job_amount'];
    jobRemarks = json['job_remarks'];
    jobStatus = json['job_status'];
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
    product =
    json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['driver_id'] = this.driverId;
    data['job_system_id'] = this.jobSystemId;
    data['product_id'] = this.productId;
    data['job_date'] = this.jobDate;
    data['job_qty'] = this.jobQty;
    data['job_vat'] = this.jobVat;
    data['job_amount'] = this.jobAmount;
    data['job_remarks'] = this.jobRemarks;
    data['job_status'] = this.jobStatus;
    if (this.customer != null) {
      data['customer'] = this.customer.toJson();
    }
    if (this.product != null) {
      data['product'] = this.product.toJson();
    }
    return data;
  }
}

class Customer {
  int customerId;
  String customerAccountnumber;
  String customerBusinessname;
  String customerAddress1;
  String customerAddress2;
  String customerAddress3;
  String postcode;
  int zoneId;
  String customerPrimarycontact;
  String customerPrimarycontactemail;
  String customerPrimaryphone;
  String customerLat;
  String customerLng;
  int customerAccounttype;

  Customer(
      {this.customerId,
        this.customerAccountnumber,
        this.customerBusinessname,
        this.customerAddress1,
        this.customerAddress2,
        this.customerAddress3,
        this.postcode,
        this.zoneId,
        this.customerPrimarycontact,
        this.customerPrimarycontactemail,
        this.customerPrimaryphone,
        this.customerLat,
        this.customerLng,
        this.customerAccounttype});

  Customer.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    customerAccountnumber = json['customer_accountnumber'];
    customerBusinessname = json['customer_businessname'];
    customerAddress1 = json['customer_address1'];
    customerAddress2 = json['customer_address2'];
    customerAddress3 = json['customer_address3'];
    postcode = json['postcode'];
    zoneId = json['zone_id'];
    customerPrimarycontact = json['customer_primarycontact'];
    customerPrimarycontactemail = json['customer_primarycontactemail'];
    customerPrimaryphone = json['customer_primaryphone'];
    customerLat = json['customer_lat'];
    customerLng = json['customer_lng'];
    customerAccounttype = json['customer_accounttype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customer_id'] = this.customerId;
    data['customer_accountnumber'] = this.customerAccountnumber;
    data['customer_businessname'] = this.customerBusinessname;
    data['customer_address1'] = this.customerAddress1;
    data['customer_address2'] = this.customerAddress2;
    data['customer_address3'] = this.customerAddress3;
    data['postcode'] = this.postcode;
    data['zone_id'] = this.zoneId;
    data['customer_primarycontact'] = this.customerPrimarycontact;
    data['customer_primarycontactemail'] = this.customerPrimarycontactemail;
    data['customer_primaryphone'] = this.customerPrimaryphone;
    data['customer_lat'] = this.customerLat;
    data['customer_lng'] = this.customerLng;
    data['customer_accounttype'] = this.customerAccounttype;
    return data;
  }
}

class Product {
  int productId;
  String productName;
  String productEwc;
  int productForm;

  Product(
      {this.productId, this.productName, this.productEwc, this.productForm});

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
    productEwc = json['product_ewc'];
    productForm = json['product_form'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    data['product_ewc'] = this.productEwc;
    data['product_form'] = this.productForm;
    return data;
  }
}

class Meta {
  int totalCount;
  int pageCount;
  int currentPage;
  int perPage;

  Meta({this.totalCount, this.pageCount, this.currentPage, this.perPage});

  Meta.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    pageCount = json['pageCount'];
    currentPage = json['currentPage'];
    perPage = json['perPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    data['pageCount'] = this.pageCount;
    data['currentPage'] = this.currentPage;
    data['perPage'] = this.perPage;
    return data;
  }
}