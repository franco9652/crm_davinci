import 'package:flutter/material.dart';

class ModernPaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final bool isLoading;

  const ModernPaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Row(
        children: [
          
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.pages, color: Color(0xFF6366F1), size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            '$currentPage de $totalPages',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 20), 
               
                  _buildCompactNavigationButton(
                    icon: Icons.chevron_left,
                    onPressed: currentPage > 1 && !isLoading
                        ? () => onPageChanged(currentPage - 1)
                        : null,
                  ),
                  
                  const SizedBox(width: 8),
                  
                  
                  ..._buildCompactPageNumbers(),
                  
                  const SizedBox(width: 8),
                  
                 
                  _buildCompactNavigationButton(
                    icon: Icons.chevron_right,
                    onPressed: currentPage < totalPages && !isLoading
                        ? () => onPageChanged(currentPage + 1)
                        : null,
                  ),
                  
                  const SizedBox(width: 20), 
                ],
              ),
            ),
          ),
          
         
          if (isLoading) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isEnabled 
                ? const Color(0xFF6366F1).withOpacity(0.1)
                : const Color(0xFF334155).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isEnabled 
                  ? const Color(0xFF6366F1).withOpacity(0.3)
                  : const Color(0xFF334155).withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            color: isEnabled 
                ? const Color(0xFF6366F1)
                : Colors.white.withOpacity(0.3),
            size: 16,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCompactPageNumbers() {
    List<Widget> pages = [];
    
    if (totalPages <= 5) {
      
      for (int i = 1; i <= totalPages; i++) {
        pages.add(_buildCompactPageButton(i));
        if (i < totalPages) pages.add(const SizedBox(width: 4));
      }
    } else {
      
      int start = (currentPage - 2).clamp(1, totalPages - 4);
      int end = (start + 4).clamp(5, totalPages);
      
     
      if (end == totalPages) {
        start = (totalPages - 4).clamp(1, totalPages);
      }
      
      for (int i = start; i <= end; i++) {
        pages.add(_buildCompactPageButton(i));
        if (i < end) pages.add(const SizedBox(width: 4));
      }
    }
    
    return pages;
  }

  Widget _buildCompactPageButton(int pageNumber) {
    final isSelected = pageNumber == currentPage;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : () => onPageChanged(pageNumber),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1)
                : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF334155).withOpacity(0.3),
            ),
          ),
          child: Text(
            pageNumber.toString(),
            style: TextStyle(
              color: isSelected 
                  ? Colors.white 
                  : Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

}
