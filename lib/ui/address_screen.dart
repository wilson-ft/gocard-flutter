import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:meet_queue_volunteer/bloc/address_bloc.dart';
import 'package:meet_queue_volunteer/response/user_response.dart';
import 'package:meet_queue_volunteer/ui/photo_screen.dart';
import 'package:provider/provider.dart';
import 'package:meet_queue_volunteer/helper.dart';

import '../constants.dart';

class AddressScreen extends StatefulWidget {

  static const routeName = '/address';

  AddressScreen();

  @override
  State<StatefulWidget> createState() => new _AddressScreen();
}
  
class _AddressScreen extends State<AddressScreen>{

  final TextEditingController _postalController = new TextEditingController();
  final TextEditingController _blkHseController = new TextEditingController();
  final TextEditingController _floorController = new TextEditingController();
  final TextEditingController _unitController = new TextEditingController();
  final TextEditingController _addressController = new TextEditingController();
  final TextEditingController _flatController = new TextEditingController();
  final StreamController<String> _raceStreamController = new StreamController<String>();
  // final String token;
  final RegExp postalExp = new RegExp(
    r"^\d{6}$",
    caseSensitive: false,
    multiLine: false,
  );

  final _formKey = GlobalKey<FormState>();
  UserData userData;
  // String selectedValue;

  final Helper helper = new Helper();

  String selectedValue;

  void updateControllers() {
    _postalController.text = userData.postalCode?.toString(); // required field
    _blkHseController.text = userData.blockHseNo?.toString(); // required field
    _floorController.text = userData.floorNo;
    _unitController.text = userData.unitNo;
    _addressController.text = userData.address; // required field
    _flatController.text = userData.flatType; // required field
  }

  @override
  void initState() {
    super.initState();
    // Update controllers values after build is done.
    // Not updated in build to avoid values getting updated on every change.
    // This is put in initState so it's only called once.
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => updateControllers());
    }
  }

  @override
  Widget build(BuildContext context) {
      
    // Extract the arguments from the current ModalRoute settings and cast
    // them as UserData.
    userData = ModalRoute.of(context).settings.arguments;

    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Center(child: SingleChildScrollView(
        reverse: true,
        child: Padding(padding: EdgeInsets.only(bottom: bottom),
          child: new GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              }, 
            child: Form(
              key: _formKey,
              autovalidate: false,
              child: makeBody()
            )
          )
      ))));
  }
    
  Widget makeBody() {
    return Provider<AddressBloc>(
      create: (context) => AddressBloc(
        userData: userData,
        postalController: _postalController,
        blkHseController: _blkHseController,
        floorController: _floorController,
        unitController: _unitController,
        addressController: _addressController,
        flatController: _flatController
        ),
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget> [
        // Header
        Row(children: <Widget>[
          SizedBox(width: 180),
          // Progress
          Expanded(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget> [
              drawHeader("Personal Information", BLACK_HEADER_DISABLED),
              drawHeader("Address", BLACK_HEADER_HIGHLIGHT),
              drawHeader("Photo", BLACK_HEADER_DISABLED),
              drawHeader("Subject", BLACK_HEADER_DISABLED),            
            ]
          )), 
          // Cancel button
          SizedBox(width: 180, child: drawCancelButton(context))
        ]),
        // Content column with four rows inside
        // Expanded(child: // Disable this if centered is required
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 60, top: 64, right: 60, bottom: 0),
            child: 
              Row(
                children: <Widget> [
                // Back button
                showNavigationButton(true),
                // Left input fields
                Expanded(flex: 1, child: firstRow()),
                SizedBox(width: 45),
                // Right input fields
                Expanded(flex: 1, child: secondRow()),
                // Next button
                showNavigationButton(false)
              ]
          )),
      ]
    ));
  }

  Widget drawHeader(String name, Color color) {
    return 
      Center(
        child: 
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            child: Text(
              name,
              style: TextStyle(
                color: color, 
                fontFamily: 'Circular Std',
                fontSize: 24,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400
              ),
    )));
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: BLUE_INPUT_BORDER,
        width: 1.0
      ),
      borderRadius: BorderRadius.all(
          Radius.circular(5.0) 
      ),
    );
  }

  OutlineInputBorder textFieldDecoration() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: BLUE_INPUT_BORDER, width: 1),
    );
  } 

  Widget firstRow() {
    return Container(width: double.infinity, // Match parent
        padding: const EdgeInsets.only(left: 60, top: 0, right: 0, bottom: 0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            showLabel('Postal Code'),
            showPostalInput('876543', _postalController, true),
            SizedBox(height: 50),
            // Floor row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: showLabel('Floor')),
                  SizedBox(width: 40),
                  Expanded(child: showLabel('Unit')),
              ]),
            // Floor input
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: showCommonInput('01', _floorController, false),),
                  SizedBox(width: 40),
                  Expanded(child: showCommonInput('4321', _unitController, false),),
              ]),
            SizedBox(height: 50),
            showLabel('Flat Type'),
            showCommonInput('Flat Type', _flatController, false),
            // showOccupationDropDown(),
            showMsg(),
    ]));
  }

  Widget secondRow() {
    return Container(width: double.infinity, // Match parent
        padding: const EdgeInsets.only(left: 0, top: 0, right: 60, bottom: 0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            showLabel('Block / House Number'),
            showCommonInput('01', _blkHseController, true),
            SizedBox(height: 50),
            showLabel('Street Address'),
            showCommonInput('Upper Thompson Road', _addressController, true),
            SizedBox(height: 50),
            // Show a hidden textfield on the right and also providing
            // the same controller to ensure even after validation,
            // both rows remain aligned.
            Opacity(opacity: 0.0, child: showLabel('')),
            Opacity(opacity: 0.0, child: showCommonInput('Flat Type', _flatController, false)),
    ]));
  }

  // Not using List<Widget> because
  // "This requires the 'spread-collections' experiment to be enabled."
  Widget showLabel(String name) {
    return 
      Container(width: double.infinity, // Match parent
        padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 15),
        child:
          Text(
            name,
            style: TextStyle(
              color: BLACK_TEXT, 
              fontFamily: 'SourceSansPro',
              fontSize: 18,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.normal)
    ));
  }

  // Input that doesn't need to use UserBloc, hence no need for rebuild, 
  // controllers will help update the text value.
  Widget showCommonInput(String hint, TextEditingController controller, bool isRequired) {
    return 
      Padding(
        padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
          child: TextFormField(
            controller: controller,
            maxLines: 1,
            autofocus: false,
            decoration: new InputDecoration(
              hintText: hint,
              enabledBorder: textFieldDecoration(),
              focusedBorder: textFieldDecoration(),
              border: textFieldDecoration(),
              errorBorder: textFieldDecoration(),
              disabledBorder: InputBorder.none,
            ),
            validator: (value) {
              if (isRequired && value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            onSaved: (value) => controller.text = value,
      ));
  }

  Widget showPostalInput(String hint, TextEditingController controller, bool isRequired) {
    return 
      Padding(
        padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
          child: TextFormField(
            controller: controller,
            maxLines: 1,
            autofocus: false,
            decoration: new InputDecoration(
              hintText: hint,
              enabledBorder: textFieldDecoration(),
              focusedBorder: textFieldDecoration(),
              border: textFieldDecoration(),
              errorBorder: textFieldDecoration(),
              disabledBorder: InputBorder.none,
            ),
            validator: (value) {
              if (isRequired && !postalExp.hasMatch(value)) {
                return 'Postal code has to be 6-digit.';
              }
              return null;
            },
            onSaved: (value) => controller.text = value,
      ));
  }

  Widget showDateSelector(String hint) {
    return 
      Consumer<AddressBloc>(
        builder: (context, userBloc, child) {
          return Container(padding: const EdgeInsets.only(left: 15, top: 0, right: 0, bottom: 0),
            decoration: myBoxDecoration(),
            child:
            Stack(
              alignment: Alignment.centerRight, 
              children: <Widget>[
                TextFormField(
                  maxLines: 1,
                  autofocus: false,
                  enabled: false,
                  controller: userBloc.unitController,
                  decoration: new InputDecoration(
                    hintText: hint,
                    icon: new Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                )),
                Container(
                  decoration: 
                    BoxDecoration(
                      color: BLUE_ICON_BUTTON,
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  child: IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () async {
                    // Format date to the appropriate format
                    DateTime tempDate = new DateFormat(DATE_FORMAT).parse(userBloc.unitController?.text);
                    DateTime selectedDate = await showDatePicker(
                      context: context,
                      initialDate: (userBloc.unitController?.text == null) ? DateTime.now() : tempDate,//DateTime.now(),//
                      firstDate: DateTime(1920),
                      lastDate: DateTime(2030),
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.dark(),
                          child: child,
                        );
                      },
                    );
                    userBloc?.unitController?.text = DateFormat(DATE_FORMAT).format(selectedDate);
                })),
              ],
            )
          );
    }); 
  }

  Widget showConsumerDropDownButton(String hint, List<String> items) {
      return  
        StreamBuilder<String>(
          stream: _raceStreamController.stream,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          // (context, userBloc, child) {

            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');

            // int index = items.indexOf(userBloc.user.race);
            // if (index > -1)
            //     selectedValue = items[index];

            return new DropdownButtonFormField<String>(
              value: snapshot.data,//index > -1 ? items[index] : null,
              hint: new Text(hint,
                textAlign: TextAlign.center),
              isExpanded: true,
              items: items.map((String value) {
                return new DropdownMenuItem<String>(
                  child: new Text(value),
                  value: value
                );
              }).toList(),
              validator: (value) => value == null ? 'field required' : null,
              onChanged: (value) {selectedValue = value;},
            );
          });
    }

  Widget showDropDownButton(String hint, List<String> items, TextEditingController controller) {
    return DropdownButtonFormField<String>(
            value: [""].contains(controller.text) ? items[0] : items[1],
            hint: new Text(hint,
              textAlign: TextAlign.center),
            isExpanded: true,
            items: items.map((String value) {
              return new DropdownMenuItem<String>(
                child: new Text(value),
                value: value
              );
            }).toList(),
            validator: (value) => value == null ? 'field required' : null,
            onChanged: (value) =>controller.text = value,
          );
  }

  Widget showNavigationButton(bool isBack) {
    IconData iconData = isBack ? Icons.arrow_back_ios : Icons.arrow_forward_ios;

    return Consumer<AddressBloc>(builder: (context, addressBloc, child) {
      return Container(
        decoration: 
          BoxDecoration(
            color: BLUE_ICON_BUTTON,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
        child: 
          IconButton(
            icon: Icon(iconData, color: Colors.white),
            onPressed: () async {
              // Next button
              if (!isBack) {
                // No error with inputs
                if (_formKey.currentState.validate()) {
                  UserResponse updateOrCreateResponse;
                  try {
                  // If the form is valid and uid exists, update user.
                  if (!(["", null, false, 0]).contains(addressBloc.userData.uid)) {
                    _formKey.currentState.save();
                    updateOrCreateResponse = await addressBloc.updateUser();
                  } 
                  // If the form is valid and uid doesn't exist, create user.
                  else {
                    updateOrCreateResponse = await addressBloc.createUser();
                  }

                  // Display response
                  if (updateOrCreateResponse == null)
                      helper.displayToast(ERROR_NULL_RESPONSE);
                    else {
                      helper.displayToast(updateOrCreateResponse.message);
                      Navigator.of(context).pushNamedAndRemoveUntil(PhotoScreen.routeName, (Route<dynamic> route) => false);
                    }
                  } catch(e) {
                      // If error is unauthorised
                      if (e.toString() == ERROR_UNAUTHORISED)
                        navigateToRoot();
                    }
                }
              } 
              // Back button
              else {
                Navigator.pop(context);
              }
            })
      );
    });
  }

  Widget showMsg() {
    return 
      Consumer<AddressBloc>(
        builder: (context, userBloc, child) {

          if (userBloc.msg != "User not found.")
            helper.displayToast(userBloc.msg);
          if (userBloc.errorMsg != "" && userBloc.errorMsg != "User not found.")
            helper.displayToast(userBloc.errorMsg);
          
          return Container();
      });
    }

  Widget drawCancelButton(context) {
    return
      Container(padding: const EdgeInsets.only(left: 0, top: 0, right: 60, bottom: 0),
          alignment: Alignment.centerRight,
          child: 
            IconButton(
              icon: Image(image: AssetImage('assets/images/cancel.png'), color: Colors.red),
              onPressed: () {
                navigateToRoot();
              }),
      );
  }

  void navigateToRoot() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  @override
  void dispose() {
      super.dispose();
        _postalController.dispose();
        _blkHseController.dispose();
        _floorController.dispose();
        _unitController.dispose();
        _addressController.dispose();
        _flatController.dispose();
        _raceStreamController.close();
    } 
  }

  