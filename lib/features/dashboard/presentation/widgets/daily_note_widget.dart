import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DailyNoteWidget extends StatelessWidget {
  final Map<String, dynamic>? note;
  final VoidCallback onAddNote;

  const DailyNoteWidget({
    Key? key,
    this.note,
    required this.onAddNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasNote = note != null;
    final content = note?['content'] as String? ?? '';
    final tags = (note?['tags'] as List?)?.cast<String>() ?? [];

    // Cores
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF2D3142);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF9E9E9E);
    final innerCardBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA);
    final borderColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF0F0F0);
    final buttonBg = isDark ? const Color(0xFF263238) : const Color(0xFF2D3142);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Notas',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            
            SizedBox(height: 2.h),
            
            if (hasNote) 
              _buildNoteContent(
                context, content, tags, innerCardBg, borderColor, textPrimary, textSecondary,
              )
            else 
              _buildEmptyState(
                context, innerCardBg, borderColor, textPrimary, textSecondary, buttonBg,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color innerCardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color buttonBg,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: innerCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Text(
            'Como foi o seu dia?',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            'Acompanhe sua saúde e sentimentos',
            style: TextStyle(
              fontSize: 10.sp,
              color: textSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          
          // Emoji Icons - Estilo Yazio
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMoodEmoji('☀️', const Color(0xFFFFF3E0)),
              SizedBox(width: 3.w),
              _buildMoodEmoji('🌧️', const Color(0xFFE3F2FD)),
              SizedBox(width: 3.w),
              _buildMoodEmoji('⚡', const Color(0xFFF3E5F5)),
            ],
          ),
          
          SizedBox(height: 2.5.h),
          
          // Add Note Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAddNote,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.3.h),
                decoration: BoxDecoration(
                  color: buttonBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Adicionar Nota',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEmoji(String emoji, Color bgColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }

  Widget _buildNoteContent(
    BuildContext context,
    String content,
    List<String> tags,
    Color innerCardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Note content if exists
        if (content.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: innerCardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 11.sp,
                color: textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
        
        // Tags and Add button row
        Row(
          children: [
            // Add Button
            _buildAddButton(context, isDark, borderColor, textPrimary),
            
            SizedBox(width: 3.w),
            
            // Tags
            if (tags.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: tags.map((tag) => _buildTag(tag, innerCardBg, borderColor, textPrimary)).toList(),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, bool isDark, Color borderColor, Color textPrimary) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddNote,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 22,
                color: textPrimary,
              ),
              const SizedBox(height: 2),
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 9.sp,
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag, Color bgColor, Color borderColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      height: 54,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
