// En tu ConfigPage existante, agrega este widget donde quieras mostrar notas diarias:

// Nota Diaria (RF 70 - Capítulo II)
Widget _buildDailyNotesSection() {
  return FutureBuilder<String?>(
    future: ConfigRepository().obtenerNotaDiaria(),
    builder: (context, snapshot) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notas Diarias (RF 70)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Escribe tus notas aquí...',
                  border: OutlineInputBorder(),
                  fillColor: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[900] 
                      : Colors.grey[100],
                  filled: true,
                ),
                maxLines: 4,
                onChanged: (val) {
                  ConfigRepository().guardarNotaDiaria(val);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
