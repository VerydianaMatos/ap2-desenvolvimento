import 'package:flutter/material.dart';
import '../models/country_model.dart';
import '../services/api_service.dart';
import '../widgets/country_card.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Country>> _countriesFuture;
  List<Country> _allCountries = [];
  List<Country> _filteredCountries = [];
  List<String> _regions = [];
  String _selectedRegion = 'Todas';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _countriesFuture = ApiService().fetchCountries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadCountries() {
    setState(() {
      _searchController.clear();
      _allCountries = [];
      _filteredCountries = [];
      _regions = [];
      _selectedRegion = 'Todas';
      _countriesFuture = ApiService().fetchCountries();
    });
  }

  void _applyFilters() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      List<Country> result = _allCountries;

      if (_selectedRegion != 'Todas') {
        result = result.where((c) => c.region == _selectedRegion).toList();
      }

      if (q.isNotEmpty) {
        result = result.where((c) {
          return c.name.toLowerCase().contains(q) ||
              c.capital.toLowerCase().contains(q);
        }).toList();
      }

      _filteredCountries = result;
    });
  }

  void _onSearchChanged(String query) => _applyFilters();

  void _onRegionSelected(String region) {
    setState(() => _selectedRegion = region);
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF0F5),
      body: SafeArea(
        child: FutureBuilder<List<Country>>(
          future: _countriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFD63384)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          color: Color(0xFFE57373), size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar dados:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFFE57373), fontSize: 15),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _reloadCountries,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Tentar novamente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD63384),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasData) {
              if (_allCountries.isEmpty) {
                _allCountries = snapshot.data!;
                _filteredCountries = _allCountries;

                final regionSet = _allCountries
                    .map((c) => c.region)
                    .where((r) => r != 'Desconhecida')
                    .toSet()
                    .toList()
                  ..sort();
                _regions = ['Todas', ...regionSet];
              }

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD63384),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌍 Países do Mundo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_filteredCountries.length} países encontrados',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Buscar por nome ou capital...',
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontSize: 14),
                              prefixIcon: const Icon(Icons.search_rounded,
                                  color: Color(0xFFD63384)),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _applyFilters();
                                },
                              )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _regions.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final region = _regions[index];
                              final isSelected = region == _selectedRegion;
                              return GestureDetector(
                                onTap: () => _onRegionSelected(region),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white38,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    region,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFFD63384)
                                          : Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filteredCountries.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 56, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum resultado encontrado.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 15),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: _filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        return CountryCard(
                          country: country,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailsScreen(country: country),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Nenhum país encontrado.'));
          },
        ),
      ),
    );
  }
}