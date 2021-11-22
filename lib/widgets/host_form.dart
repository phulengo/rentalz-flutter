import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:location/location.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:rentalz_flutter/services/db.dart';

// Define a custom Form widget.
class HostForm extends StatefulWidget {
  const HostForm({Key? key}) : super(key: key);

  @override
  HostFormState createState() {
    return HostFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class HostFormState extends State<HostForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  var _isFormValid = false;

  String? propertyId;

  // Static data
  final _propertyTypeOptions = [
    "Apartment",
    "House",
    "Botique hotel",
    "Bungelow",
    "Flat",
    "Unique Space",
    "Homestay"
  ];

  final _funitureTypeOptions = ["Furnished", "Unfurnished", "Part Furnished"];

  @override
  void initState() {
    super.initState();
  }

  _handleSavePressed(User user) async {
    _formKey.currentState?.save();
    final formData = _formKey.currentState?.value;

    DatabaseService db = DatabaseService();
    var newProperty = await db.setNewProperty(formData, user);

    return newProperty;
  }

  _loadNewProperty(User user) async {
    var newProperty = await _handleSavePressed(user);
    var newPropertyId = newProperty?.id;
    setState(() {
      propertyId = newPropertyId;
    });
    return newPropertyId;
  }

  _goToPropertyPage(User user, String userId) async {
    var newPropertyId = await _loadNewProperty(user);
    DatabaseService db = DatabaseService();
    var newPropertyData = await db.getProperty(userId, newPropertyId);

    return Future.delayed(const Duration(milliseconds: 250), () {
      Navigator.of(context).popAndPushNamed("/property", arguments: {
        'property': newPropertyData,
        'propertyId': newPropertyId,
        'liked': false
      });
    });
  }

  // Form controllers
  var _nameController = TextEditingController();
  var _addressController = TextEditingController();
  var _noteController = TextEditingController();
  var _reporterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User?>(context);

    // Build a Form widget using the _formKey created above.
    return user != null
        ? FormBuilder(
            key: _formKey,
            onChanged: () {
              setState(() {
                _isFormValid = _formKey.currentState!.validate();
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Basic information
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ("Basic Information".toUpperCase()),
                        style: const TextStyle(fontWeight: FontWeight.w300),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                        child: FormBuilderTextField(
                          controller: _nameController,
                          name: 'propertyName',
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.house_outlined),
                              suffixIcon: _nameController.text.isNotEmpty
                                  ? IconButton(
                                      icon:
                                          const Icon(Icons.backspace_outlined),
                                      onPressed: () {
                                        _nameController.clear();
                                      },
                                    )
                                  : null,
                              hintText: "Enter the name of your property",
                              labelText: "Name of property",
                              border: const OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Property's name cannot be blank";
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.always,
                        ),
                      ),

                      // Property's address
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                        child: Column(
                          children: [
                            FormBuilderTextField(
                              name: 'propertyAddress',
                              controller: _addressController,
                              decoration: InputDecoration(
                                prefixIcon:
                                    const Icon(Icons.navigation_outlined),
                                hintText: "Enter the adress of your property",
                                labelText: "Location of property",
                                border: const OutlineInputBorder(),
                                suffixIcon: _addressController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                            Icons.backspace_outlined),
                                        onPressed: () {
                                          _addressController.clear();
                                        },
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Property's location cannot be blank";
                                }
                                return null;
                              },
                              autovalidateMode: AutovalidateMode.always,
                              keyboardType: TextInputType.streetAddress,
                            ),
                            TextButton(
                                onPressed: () {
                                  // TODO: Use current location feature
                                },
                                child: Row(
                                  children: const [
                                    Icon(Icons.location_on_outlined),
                                    Text("Use current location",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400))
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // A few more details
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ("A few more details".toUpperCase()),
                        style: const TextStyle(fontWeight: FontWeight.w300),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                          child: FormBuilderDropdown(
                            name: 'propertyType',
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.apartment_outlined),
                              hintText: "Select type of your property",
                              labelText: "Type of property",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return "Property's type cannot be blank";
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.always,
                            items: _propertyTypeOptions.map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                          child: FormBuilderTextField(
                            name: 'bedroomAmount',
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.bed_outlined),
                              hintText: "Enter number of bedrooms",
                              labelText: "Number of bedrooms",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                          child: FormBuilderDropdown(
                            name: 'furnitureType',
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.chair_outlined),
                              hintText:
                                  "Select type of your property's furniture",
                              labelText: "Type of furniture",
                              border: OutlineInputBorder(),
                            ),
                            items: _funitureTypeOptions.map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                          )),
                    ],
                  ),
                ),

                // Prices & Notes
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ("Prices & Notes".toUpperCase()),
                        style: const TextStyle(fontWeight: FontWeight.w300),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                        child: FormBuilderTextField(
                          name: 'propertyMonthlyPrice',
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.paid_outlined),
                            hintText:
                                "Enter the monthly rent price of your property",
                            labelText: "Monthly rent price",
                            border: OutlineInputBorder(),
                            //
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Property's monthly rent price cannot be blank";
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.always,
                          inputFormatters: [
                            CurrencyTextInputFormatter(
                              locale: 'en',
                              decimalDigits: 0,
                              symbol: "\$",
                            )
                          ],
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                        child: FormBuilderTextField(
                          name: 'propertyNotes',
                          controller: _noteController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.notes_outlined),
                            hintText: "Enter notes of your property",
                            labelText: "Notes",
                            border: const OutlineInputBorder(),
                            suffixIcon: _noteController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.backspace_outlined),
                                    onPressed: () {
                                      _noteController.clear();
                                    },
                                  )
                                : null,

                            //
                          ),
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ],
                  ),
                ),

                // Reporter
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    ("Reporter".toUpperCase()),
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                    child: FormBuilderTextField(
                      name: 'reporterName',
                      controller: _reporterController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline_outlined),
                        hintText: "Enter the name of reporter",
                        labelText: "Name of reporter",
                        border: const OutlineInputBorder(),
                        suffixIcon: _reporterController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.backspace_outlined),
                                onPressed: () {
                                  _reporterController.clear();
                                },
                              )
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Reporter's name cannot be blank";
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.always,
                    ),
                  ),
                ]),

                // Hidden date added
                Visibility(
                    maintainState: true,
                    visible: false,
                    child: FormBuilderDateTimePicker(
                      name: 'dateAdded',
                      initialValue: DateTime.now(),
                      decoration: const InputDecoration(
                        labelText: "Pick added date",
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                        //
                      ),
                    )),
                Visibility(
                    maintainState: true,
                    visible: false,
                    child: FormBuilderTextField(
                      name: 'createdBy',
                      initialValue: user.uid,
                      decoration: const InputDecoration(
                        labelText: "Created by",
                        border: OutlineInputBorder(),
                        //
                      ),
                    )),

                // Save button
                Container(
                    padding: const EdgeInsets.fromLTRB(0, 32, 0, 32),
                    child: OutlinedButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate()) {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title:
                                          const Text('Did you finish editing?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    const Text('Saving Data'),
                                                duration:
                                                    const Duration(seconds: 1),
                                              ),
                                            );
                                            _goToPropertyPage(user, user.uid);
                                          },
                                          child: const Text('Yes'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('No'),
                                        ),
                                      ],
                                    ));
                          } else {}
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                            backgroundColor: _isFormValid
                                ? Colors.black
                                : Colors.grey.shade300,
                            primary: Colors.white,
                            side: BorderSide(
                                width: 0,
                                color: _isFormValid
                                    ? Colors.black
                                    : Colors.grey.shade300),
                            minimumSize: const Size(double.infinity, 60),
                            shadowColor: null))),
              ],
            ),
          )
        : const Text("You need to login!");
  }
}
