import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class ResponsiveTable<T> extends StatelessWidget {
  final List<String> columns;
  final List<T> data;
  final List<Widget Function(T item)> cellBuilders;
  final double? rowHeight;
  final Color headerBackgroundColor;
  final Color rowBackgroundColor;
  final Color borderColor;
  final TextStyle? headerStyle;
  final TextStyle? cellStyle;
  final EdgeInsets padding;
  final VoidCallback? onRefresh;
  
  const ResponsiveTable({
    Key? key,
    required this.columns,
    required this.data,
    required this.cellBuilders,
    this.rowHeight = 56.0,
    this.headerBackgroundColor = Colors.grey,
    this.rowBackgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    this.headerStyle,
    this.cellStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    this.onRefresh,
  }) : assert(columns.length == cellBuilders.length, 'Column count must match cellBuilders count'),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildHorizontalScrollableTable(context, constraints);
      },
    );
  }
  
  // Horizontal scrollable table layout for all screen sizes
  Widget _buildHorizontalScrollableTable(BuildContext context, BoxConstraints constraints) {
    final defaultHeaderStyle = GoogleFonts.poppins(
      color: Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
    
    final defaultCellStyle = GoogleFonts.poppins(
      color: Colors.black87,
      fontSize: 14,
    );
    
    // Calculate minimum column width to ensure table is properly displayed
    final minColumnWidth = columns.length <= 4 ? 120.0 : 100.0;
    final tableWidth = minColumnWidth * columns.length;
    final useScrollView = tableWidth > constraints.maxWidth;
    
    // Calculate table height based on content
    final double headerHeight = 50.0; // Header row height
    final double dividerHeight = 2.0;  // Height of divider between header and rows
    final double emptyStateHeight = data.isEmpty ? 100.0 : 0.0;
    
    // Calculate rows height based on data
    final double rowsHeight = data.isEmpty 
        ? 0.0 
        : data.length * rowHeight! + (data.length - 1); // Include dividers between rows
    
    // Total table height
    final double tableHeight = headerHeight + dividerHeight + 
        (data.isEmpty ? emptyStateHeight : rowsHeight);
    
    // Main table widget
    Widget tableContent = Container(
      decoration: BoxDecoration(
        color: AppPallete.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: useScrollView ? tableWidth : constraints.maxWidth,
      height: tableHeight, // Set explicit height
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              color: headerBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: columns.asMap().entries.map((entry) {
                int idx = entry.key;
                String column = entry.value;
                // Assign flex values based on column content type
                int flex = _getColumnFlex(idx);
                
                return Expanded(
                  flex: flex,
                  child: Container(
                    padding: padding,
                    constraints: BoxConstraints(
                      minWidth: minColumnWidth,
                    ),
                    child: Text(
                      column,
                      style: headerStyle ?? defaultHeaderStyle,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Divider Line
          Container(
            height: dividerHeight,
            color: borderColor,
          ),
          
          // Data Rows
          if (data.isEmpty)
            SizedBox(
              height: emptyStateHeight,
              child: Center(
                child: Text(
                  'No data available',
                  style: defaultCellStyle,
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: index % 2 == 0 ? rowBackgroundColor : rowBackgroundColor.withOpacity(0.9),
                            ),
                            child: Row(
                              children: cellBuilders.asMap().entries.map((cellEntry) {
                                int columnIndex = cellEntry.key;
                                var buildCell = cellEntry.value;
                                // Use the same flex value as in header
                                int flex = _getColumnFlex(columnIndex);
                                
                                return Expanded(
                                  flex: flex,
                                  child: Container(
                                    padding: padding,
                                    constraints: BoxConstraints(
                                      minWidth: minColumnWidth,
                                    ),
                                    child: DefaultTextStyle(
                                      style: cellStyle ?? defaultCellStyle,
                                      child: buildCell(item),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        if (index < data.length - 1)
                          Container(
                            height: 1,
                            color: borderColor.withOpacity(0.3),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
    
    // Wrap in SingleChildScrollView for horizontal scrolling if needed
    return useScrollView
      ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: tableContent,
        )
      : tableContent;
  }
  
  // Helper function to determine column flex based on content type
  int _getColumnFlex(int columnIndex) {
    // Customize flex values based on your specific columns
    // For example, make date columns narrower, description columns wider
    
    // Default equal flex for all columns
    if (columnIndex < 0 || columnIndex >= columns.length) return 1;
    
    // Example: Adjust flex based on column name/index
    final columnName = columns[columnIndex].toLowerCase();
    
    if (columnName.contains('tanggal')) {
      return 3; // Wider for dates
    } else if (columnName.contains('nomor')) {
      return 2; // Medium width for IDs
    } else if (columnName.contains('deskripsi') || columnName.contains('ringkasan')) {
      return 4; // Widest for descriptions
    }
    
    // Default equal distribution
    return 2;
  }
}