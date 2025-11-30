import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../models/trip_model.dart';
import '../../providers/trip_provider.dart';

class EditTripPage extends StatefulWidget {
  final Trip trip;
  const EditTripPage({Key? key, required this.trip}) : super(key: key);

  @override
  State<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _location;
  late double _price;
  late int _seats;
  late DateTime _startDate;
  late DateTime _endDate;
  String? _image;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _title = widget.trip.title;
    _description = widget.trip.description ?? '';
    _location = widget.trip.location ?? '';
    _price = widget.trip.price;
    _seats = widget.trip.seats ?? 0;
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
    _image = widget.trip.image;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
        _image = null; // Clear the old image URL if a new image is picked
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4F8FFF)),
        title: const Text(
          'Edit Trip',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF222B45),
            fontSize: 26,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Trip',
            onPressed: () async {
              await tripProvider.deleteTrip(widget.trip.id);
              if (mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: _pickedImage != null
                                  ? (kIsWeb
                                      ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                                      : Image.file(File(_pickedImage!.path), fit: BoxFit.cover))
                                  : (widget.trip.image != null && widget.trip.image!.isNotEmpty
                                      ? Image.network(widget.trip.image!, fit: BoxFit.cover)
                                      : const Icon(Icons.add_a_photo, size: 44, color: Colors.grey)),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Color(0xFF4F8FFF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        _pickedImage != null ? _pickedImage!.name : (widget.trip.image != null && widget.trip.image!.isNotEmpty ? 'Current image' : 'Add a cover image'),
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Title
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextFormField(
                        initialValue: _title,
                        decoration: InputDecoration(
                          labelText: 'Trip Title',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4F8FFF)),
                          filled: true,
                          fillColor: Color(0xFFF2F6FF),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF4F8FFF), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF4F8FFF), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.title, color: Color(0xFF4F8FFF)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                        ),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                        onChanged: (val) => _title = val,
                        validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
                      ),
                    ),
                    // Description
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextFormField(
                        initialValue: _description,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4F8FFF)),
                          filled: true,
                          fillColor: Color(0xFFF2F6FF),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF4F8FFF), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF4F8FFF), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.description, color: Color(0xFF4F8FFF)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                        ),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                        onChanged: (val) => _description = val,
                        maxLines: 2,
                      ),
                    ),
                    // Location
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextFormField(
                        initialValue: _location,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFB614D)),
                          filled: true,
                          fillColor: Color(0xFFFFF5F2),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFFB614D), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFFB614D), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.place, color: Color(0xFFFB614D)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                        ),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                        onChanged: (val) => _location = val,
                      ),
                    ),
                    // Price & Seats Row
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: TextFormField(
                              initialValue: _price.toString(),
                              decoration: InputDecoration(
                                labelText: 'Price',
                                labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4F8FFF)),
                                filled: true,
                                fillColor: Color(0xFFF2F6FF),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF4F8FFF), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF4F8FFF), width: 2),
                                ),
                                prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF4F8FFF)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                              ),
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (val) => _price = double.tryParse(val) ?? 0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextFormField(
                              initialValue: _seats.toString(),
                              decoration: InputDecoration(
                                labelText: 'Seats',
                                labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFFA726)),
                                filled: true,
                                fillColor: Color(0xFFFFFAF2),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFFFA726), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFFFA726), width: 2),
                                ),
                                prefixIcon: const Icon(Icons.event_seat, color: Color(0xFFFFA726)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                              ),
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => _seats = int.tryParse(val) ?? 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                            title: Text(
                              _startDate.toLocal().toString().split(' ')[0],
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            leading: const Icon(Icons.calendar_today, color: Color(0xFF4F8FFF)),
                            tileColor: Colors.blue[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => _startDate = picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                            title: Text(
                              _endDate.toLocal().toString().split(' ')[0],
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            leading: const Icon(Icons.calendar_today, color: Color(0xFF4F8FFF)),
                            tileColor: Colors.blue[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: _startDate,
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => _endDate = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F8FFF),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      label: const Text('Save Changes'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String? imageUrl = _image;
                          if (_pickedImage != null) {
                            imageUrl = await tripProvider.uploadTripImage(_pickedImage!);
                          }
                          final updatedTrip = Trip(
                            id: widget.trip.id,
                            title: _title,
                            description: _description,
                            location: _location,
                            price: _price,
                            startDate: _startDate,
                            endDate: _endDate,
                            seats: _seats,
                            image: imageUrl,
                            createdAt: widget.trip.createdAt,
                          );
                          await tripProvider.updateTrip(updatedTrip);
                          if (mounted) Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
