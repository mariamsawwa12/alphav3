import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class BirthDateScreen extends StatefulWidget {
  final DateTime? initialDate;

  const BirthDateScreen({
    super.key,
    this.initialDate,
  });

  @override
  State<BirthDateScreen> createState() =>
      _BirthDateScreenState();
}

class _BirthDateScreenState
    extends State<BirthDateScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late int _selectedYear;

  DateTime get _firstAllowedDay =>
      DateTime(1900, 1, 1);

  DateTime get _lastAllowedDay {
    final now = DateTime.now();

    return DateTime(
      now.year - 18,
      now.month,
      now.day,
    );
  }

  @override
  void initState() {
    super.initState();

    final initialDate = widget.initialDate ??
        DateTime(
          _lastAllowedDay.year,
          5,
          12,
        );

    if (initialDate.isAfter(_lastAllowedDay)) {
      _selectedDay = _lastAllowedDay;
    } else if (initialDate
        .isBefore(_firstAllowedDay)) {
      _selectedDay = _firstAllowedDay;
    } else {
      _selectedDay = initialDate;
    }

    _focusedDay = _selectedDay;
    _selectedYear = _selectedDay.year;
  }

  void _selectYear(int year) {
    final safeDay = _safeDate(
      year,
      _selectedDay.month,
      _selectedDay.day,
    );

    DateTime nextDate = safeDay;

    if (nextDate.isAfter(_lastAllowedDay)) {
      nextDate = _lastAllowedDay;
    }

    if (nextDate.isBefore(_firstAllowedDay)) {
      nextDate = _firstAllowedDay;
    }

    setState(() {
      _selectedYear = year;
      _selectedDay = nextDate;
      _focusedDay = nextDate;
    });
  }

  DateTime _safeDate(
    int year,
    int month,
    int day,
  ) {
    final lastDayOfMonth =
        DateTime(year, month + 1, 0).day;

    return DateTime(
      year,
      month,
      day.clamp(1, lastDayOfMonth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = Device.width(context);
    final screenH = Device.height(context);

    final isDark =
        context.watch<Themeprovider>().isDark;

    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  screenW * 0.055,
                  18,
                  screenW * 0.055,
                  24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _Header(
                      isDark: isDark,
                      screenW: screenW,
                      onClose: () {
                        Navigator.pop(context);
                      },
                    ),

                    SizedBox(
                      height: screenH * 0.012,
                    ),

                    Text(
                      "birth_date.description".tr(),
                      style: GoogleFonts
                          .ibmPlexSansArabic(
                        color: subTextColor,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(
                      height: screenH * 0.026,
                    ),

                    Text(
                      "birth_date.year".tr(),
                      style: GoogleFonts
                          .ibmPlexSansArabic(
                        color: textColor,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 45,
                      child: ListView.separated(
                        reverse: true,
                        scrollDirection:
                            Axis.horizontal,
                        physics:
                            const BouncingScrollPhysics(),
                        itemCount:
                            _lastAllowedDay.year -
                                _firstAllowedDay.year +
                                1,
                        separatorBuilder: (_, __) =>
                            const SizedBox(
                          width: 9,
                        ),
                        itemBuilder:
                            (context, index) {
                          final year =
                              _lastAllowedDay.year -
                                  index;

                          final isSelected =
                              year ==
                                  _selectedYear;

                          return InkWell(
                            onTap: () {
                              _selectYear(year);
                            },
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds: 180,
                              ),
                              alignment:
                                  Alignment.center,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 18,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: isSelected
                                    ? primaryColor
                                    : borderColor
                                        .withOpacity(
                                          isDark
                                              ? 0.45
                                              : 0.55,
                                        ),
                                borderRadius:
                                    BorderRadius
                                        .circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : borderColor,
                                ),
                              ),
                              child: Text(
                                "$year",
                                style: GoogleFonts
                                    .ibmPlexSansArabic(
                                  color: isSelected
                                      ? Colors.white
                                      : subTextColor,
                                  fontSize: 13,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight
                                              .bold
                                          : FontWeight
                                              .w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(
                      height: screenH * 0.022,
                    ),

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.fromLTRB(
                        10,
                        8,
                        10,
                        14,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor
                            .withOpacity(0.04),
                        borderRadius:
                            BorderRadius.circular(24),
                        border: Border.all(
                          color: primaryColor,
                        ),
                      ),
                      child: TableCalendar(
                        locale: 'en_US',
                        firstDay:
                            _firstAllowedDay,
                        lastDay: _lastAllowedDay,
                        focusedDay: _focusedDay,
                        calendarFormat:
                            CalendarFormat.month,
                       availableCalendarFormats: {
  CalendarFormat.month: "birth_date.month".tr(),
},
                        selectedDayPredicate:
                            (day) {
                          return isSameDay(
                            _selectedDay,
                            day,
                          );
                        },
                        enabledDayPredicate:
                            (day) {
                          return !day.isAfter(
                                _lastAllowedDay,
                              ) &&
                              !day.isBefore(
                                _firstAllowedDay,
                              );
                        },
                        onDaySelected: (
                          selectedDay,
                          focusedDay,
                        ) {
                          setState(() {
                            _selectedDay =
                                selectedDay;
                            _focusedDay =
                                focusedDay;
                            _selectedYear =
                                selectedDay.year;
                          });
                        },
                        onPageChanged:
                            (focusedDay) {
                          setState(() {
                            _focusedDay =
                                focusedDay;
                            _selectedYear =
                                focusedDay.year;
                          });
                        },
                        daysOfWeekHeight: 28,
                        rowHeight: 46,
                        headerStyle: HeaderStyle(
                          formatButtonVisible:
                              false,
                          titleCentered: true,
                          headerPadding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 10,
                          ),
                          titleTextStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color: textColor,
                          ),
                          leftChevronIcon: Icon(
                            Icons
                                .chevron_left_rounded,
                            color: primaryColor,
                          ),
                          rightChevronIcon: Icon(
                            Icons
                                .chevron_right_rounded,
                            color: primaryColor,
                          ),
                          leftChevronMargin:
                              EdgeInsets.zero,
                          rightChevronMargin:
                              EdgeInsets.zero,
                        ),
                        daysOfWeekStyle:
                            DaysOfWeekStyle(
                          weekdayStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: subTextColor,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                          ),
                          weekendStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: subTextColor,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        calendarStyle:
                            CalendarStyle(
                          outsideDaysVisible: false,
                          isTodayHighlighted: false,
                          cellMargin:
                              const EdgeInsets.all(
                            5,
                          ),
                          defaultTextStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: textColor,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w500,
                          ),
                          weekendTextStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: textColor,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w500,
                          ),
                          disabledTextStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: subTextColor
                                .withOpacity(0.35),
                            fontSize: 12,
                          ),
                          selectedTextStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                          selectedDecoration:
                              BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: screenH * 0.02,
                    ),

                    _SelectedDateCard(
                      selectedDay:
                          _selectedDay,
                      isDark: isDark,
                      screenW: screenW,
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(
                screenW * 0.055,
                12,
                screenW * 0.055,
                MediaQuery.paddingOf(context)
                        .bottom +
                    14,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: borderColor
                        .withOpacity(0.7),
                  ),
                ),
              ),
              child: AppButton(
              text: "birth_date.confirm_date".tr(),
                isDark: isDark,
                width: double.infinity,
                height: 54,
                onPressed: () {
                  Navigator.pop(
                    context,
                    _selectedDay,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;
  final double screenW;
  final VoidCallback onClose;

  const _Header({
    required this.isDark,
    required this.screenW,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color:
                primaryColor.withOpacity(0.12),
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.cake_outlined,
            color: primaryColor,
            size: 23,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
           "birth_date.title".tr(),
            style:
                GoogleFonts.ibmPlexSansArabic(
              fontSize: screenW * 0.062,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onClose,
            borderRadius:
                BorderRadius.circular(13),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkPrimary
                        .withOpacity(0.10)
                    : AppColors.lightPrimary
                        .withOpacity(0.10),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.close_rounded,
                color: isDark
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedDateCard
    extends StatelessWidget {
  final DateTime selectedDay;
  final bool isDark;
  final double screenW;

  const _SelectedDateCard({
    required this.selectedDay,
    required this.isDark,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              primaryColor.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  primaryColor.withOpacity(0.14),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.cake_outlined,
              color: primaryColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                 "birth_date.selected_date".tr(),
                  style: GoogleFonts
                      .ibmPlexSansArabic(
                    color: subTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat(
                    'EEEE, MMMM d, yyyy',
                    'en_US',
                  ).format(selectedDay),
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: GoogleFonts
                      .ibmPlexSansArabic(
                    fontSize: screenW * 0.043,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}