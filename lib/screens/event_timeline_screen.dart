import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventTimelineScreen extends StatefulWidget {
  const EventTimelineScreen({super.key});

  @override
  _EventTimelineScreenState createState() => _EventTimelineScreenState();
}

class _EventTimelineScreenState extends State<EventTimelineScreen> {
  // Deep purple color theme
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple
  final Color lightPurple = const Color(0xFFD1C4E9); // Light Purple
  final Color accentColor = const Color(0xFF9575CD); // Medium Purple
  
  final List<Map<String, dynamic>> _timelineItems = [
    {
      "time": "2:00 PM",
      "title": "Venue Setup Begins",
      "details": ["Setup team arrives", "Decoration setup starts", "Chair and table arrangement"],
      "completed": true,
    },
    {
      "time": "3:00 PM",
      "title": "Vendor Arrivals",
      "details": ["Photographer arrives", "Florist final touches", "Music setup begins"],
      "completed": true,
    },
    {
      "time": "3:30 PM",
      "title": "Wedding Party Arrives",
      "details": ["Bride & bridesmaids arrive", "Groom & groomsmen arrive", "Final preparations"],
      "completed": false,
    },
    {
      "time": "4:00 PM",
      "title": "Ceremony Begins",
      "details": ["Guest seating", "Processional", "Exchange of vows"],
      "completed": false,
    },
    {
      "time": "5:00 PM",
      "title": "Reception",
      "details": ["Cocktail hour", "Photo session", "Guest mingling"],
      "completed": false,
    },
    {
      "time": "6:00 PM",
      "title": "Main Events",
      "details": ["Grand entrance", "First dance", "Dinner service"],
      "completed": false,
    },
    {
      "time": "8:00 PM",
      "title": "Evening Activities",
      "details": ["Cake cutting", "Dance floor opens", "Evening celebrations"],
      "completed": false,
    },
  ];

  bool _isEditMode = false;
  
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
    
    if (!_isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Timeline saved'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _addTimelineItem() {
    TextEditingController timeController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    TextEditingController detailsController = TextEditingController();
    
    // Time picker
    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              buttonTheme: const ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (picked != null) {
        timeController.text = picked.format(context);
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Add Timeline Event",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: timeController,
                      decoration: InputDecoration(
                        labelText: "Time",
                        hintText: "Select time",
                        prefixIcon: Icon(Icons.access_time, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    hintText: "Enter event title",
                    prefixIcon: Icon(Icons.event, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Details",
                    hintText: "Enter details (comma-separated)",
                    prefixIcon: Icon(Icons.list, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (timeController.text.isNotEmpty && titleController.text.isNotEmpty) {
                  setState(() {
                    _timelineItems.add({
                      "time": timeController.text,
                      "title": titleController.text,
                      "details": detailsController.text.isEmpty 
                          ? [] 
                          : detailsController.text.split(',').map((e) => e.trim()).toList(),
                      "completed": false,
                    });
                    
                    // Sort timeline items by time
                    _timelineItems.sort((a, b) {
                      // Parse time strings to comparable format
                      final aTime = _parseTimeString(a["time"]);
                      final bTime = _parseTimeString(b["time"]);
                      return aTime.compareTo(bTime);
                    });
                  });
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Timeline event added'),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  
  // Helper method to parse time strings for sorting
  DateTime _parseTimeString(String timeStr) {
    final now = DateTime.now();
    final timeParts = timeStr.split(' ');
    final timeComponents = timeParts[0].split(':');
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);
    
    // Handle PM times
    if (timeParts[1] == 'PM' && hour < 12) {
      hour += 12;
    }
    // Handle 12 AM
    if (timeParts[1] == 'AM' && hour == 12) {
      hour = 0;
    }
    
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
  
  void _deleteTimelineItem(int index) {
    setState(() {
      _timelineItems.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Timeline event deleted'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  void _toggleCompleted(int index) {
    setState(() {
      _timelineItems[index]["completed"] = !_timelineItems[index]["completed"];
    });
  }
  
  void _editTimelineItem(int index) {
    final item = _timelineItems[index];
    TextEditingController timeController = TextEditingController(text: item["time"]);
    TextEditingController titleController = TextEditingController(text: item["title"]);
    TextEditingController detailsController = TextEditingController(
      text: item["details"].join(', '),
    );
    
    // Time picker
    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              buttonTheme: const ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (picked != null) {
        timeController.text = picked.format(context);
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Edit Timeline Event",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: timeController,
                      decoration: InputDecoration(
                        labelText: "Time",
                        prefixIcon: Icon(Icons.access_time, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    prefixIcon: Icon(Icons.event, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Details",
                    hintText: "Enter details (comma-separated)",
                    prefixIcon: Icon(Icons.list, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: item["completed"],
                      activeColor: primaryColor,
                      onChanged: (value) {
                        setState(() {
                          item["completed"] = value;
                        });
                      },
                    ),
                    const Text("Mark as completed"),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (timeController.text.isNotEmpty && titleController.text.isNotEmpty) {
                  setState(() {
                    _timelineItems[index] = {
                      "time": timeController.text,
                      "title": titleController.text,
                      "details": detailsController.text.isEmpty 
                          ? [] 
                          : detailsController.text.split(',').map((e) => e.trim()).toList(),
                      "completed": item["completed"],
                    };
                    
                    // Sort timeline items by time
                    _timelineItems.sort((a, b) {
                      // Parse time strings to comparable format
                      final aTime = _parseTimeString(a["time"]);
                      final bTime = _parseTimeString(b["time"]);
                      return aTime.compareTo(bTime);
                    });
                  });
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Timeline event updated'),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              child: const Text("Update", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Event Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditMode ? 'Save' : 'Edit',
          ),
        ],
      ),
      floatingActionButton: _isEditMode ? FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _addTimelineItem,
      ) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventDetailsCard(),
          Expanded(
            child: _timelineItems.isEmpty
                ? _buildEmptyState()
                : _buildTimelineList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 70,
            color: lightPurple,
          ),
          const SizedBox(height: 16),
          Text(
            'No timeline events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add events',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Event Details Card
  Widget _buildEventDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, accentColor],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Beach Wedding",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Sarah & Michael",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildEventInfoItem(Icons.calendar_today, "Saturday, August 12, 2023"),
              const SizedBox(width: 16),
              _buildEventInfoItem(Icons.location_on, "Malibu Beach"),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  "Timeline",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${_timelineItems.where((item) => item["completed"] == true).length}/${_timelineItems.length}",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Timeline List
  Widget _buildTimelineList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _timelineItems.length,
      itemBuilder: (context, index) {
        final item = _timelineItems[index];
        final isFirst = index == 0;
        final isLast = index == _timelineItems.length - 1;
        
        return _buildTimelineItem(
          time: item["time"],
          title: item["title"],
          details: item["details"],
          completed: item["completed"],
          isFirst: isFirst,
          isLast: isLast,
          index: index,
        );
      },
    );
  }

  // Timeline Item Widget
  Widget _buildTimelineItem({
    required String time,
    required String title,
    required List<String> details,
    required bool completed,
    required bool isFirst,
    required bool isLast,
    required int index,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: completed ? Colors.grey : primaryColor,
              ),
            ),
          ),
          
          // Timeline line and dot
          Column(
            children: [
              // Top line
              if (!isFirst)
                Container(
                  width: 2,
                  height: 30,
                  color: completed ? Colors.grey.withOpacity(0.3) : lightPurple,
                ),
              
              // Dot
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: completed ? Colors.grey : primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: completed ? Colors.grey.withOpacity(0.3) : lightPurple,
                    width: 3,
                  ),
                ),
                child: completed
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
              
              // Bottom line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: index < _timelineItems.length - 1 && _timelineItems[index + 1]["completed"] == true
                        ? Colors.grey.withOpacity(0.3)
                        : lightPurple,
                  ),
                ),
            ],
          ),
          
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: completed
                    ? Border.all(color: Colors.grey.withOpacity(0.3))
                    : null,
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: completed ? Colors.grey : Colors.black,
                            decoration: completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (details.isNotEmpty) const SizedBox(height: 8),
                        ...details.map((detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "•",
                                style: TextStyle(
                                  color: completed ? Colors.grey : primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  detail,
                                  style: TextStyle(
                                    color: completed ? Colors.grey : Colors.black87,
                                    decoration: completed ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                  
                  // Edit/Delete options when in edit mode
                  if (_isEditMode)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              completed ? Icons.check_box : Icons.check_box_outline_blank,
                              color: completed ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => _toggleCompleted(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: primaryColor, size: 20),
                            onPressed: () => _editTimelineItem(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _deleteTimelineItem(index),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

