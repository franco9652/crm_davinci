import 'package:flutter/material.dart';

class CreateBudgetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1926), // Color de fondo especificado
      appBar: AppBar(
        title: Text('Crear Presupuesto'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completa los datos para crear un presupuesto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('Nombre del Cliente', 'Ej. Juan Pérez'),
              SizedBox(height: 15),
              _buildTextField('Dirección del Proyecto', 'Ej. 123 Calle Falsa'),
              SizedBox(height: 15),
              _buildDropdownField('Tipo de Proyecto', ['Casa', 'Edificio', 'Local', 'Remodelación', 'Ampliación']),
              SizedBox(height: 15),
              _buildTextField('Tamaño en m²', 'Ej. 150'),
              SizedBox(height: 15),
              _buildTextField('Presupuesto Estimado', 'Ej. 200000 USD'),
              SizedBox(height: 15),
              _buildDatePicker(context, 'Fecha de Inicio'),
              SizedBox(height: 15),
              _buildDatePicker(context, 'Fecha de Fin'),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para crear presupuesto
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C5DD3), // Color principal
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Crear Presupuesto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 5),
        TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Color(0xFF2C2A37),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Color(0xFF2C2A37),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: null,
            isExpanded: true,
            dropdownColor: Color(0xFF2C2A37),
            iconEnabledColor: Colors.white,
            underline: SizedBox(),
            hint: Text(
              'Seleccione una opción',
              style: TextStyle(color: Colors.white54),
            ),
            onChanged: (String? newValue) {
              // Manejo del valor seleccionado
            },
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: Color(0xFF6C5DD3),
                      onPrimary: Colors.white,
                      surface: Color(0xFF2C2A37),
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: Color(0xFF2C2A37),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seleccionar fecha',
                  style: TextStyle(color: Colors.white54),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
