enum CategoryType {
  quickMenu('edit_quick_menu_list', 'iconui_general_menu_more'),
  package('package', 'iconui_telco_package'),
  coupon('view_coupon_label', 'iconui_privilege_coupon'),
  privilege('bottom_navigation_privileges', 'iconui_privilege_bag'),
  faq('setting_help_label', 'iconui_general_asking'),
  none('','');

  const CategoryType(this.label, this.icon);
  final String label;
  final String icon;
}