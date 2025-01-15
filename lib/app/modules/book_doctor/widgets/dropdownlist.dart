import 'package:flutter/material.dart';
import '../../../models/pattern_model.dart';

class DropDownList extends StatelessWidget {
  final List<Pattern> patterns;
  final Pattern? selectedPattern;
  final Function(Pattern) onPatternSelected;

  const DropDownList({
    Key? key,
    required this.patterns,
    required this.selectedPattern,
    required this.onPatternSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 350,
          child: DropdownButtonFormField<Pattern>(
            decoration: InputDecoration(
              labelText: "Motif",
              hintText: "Choisissez le motif",
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(color: Colors.grey),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.merge(
              const TextStyle(color: Colors.deepPurple),
            ),
            isExpanded: true,
            items: patterns.map<DropdownMenuItem<Pattern>>((Pattern pattern) {
              return DropdownMenuItem<Pattern>(
                value: pattern,
                child: Text(
                  pattern.nom,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (Pattern? newPattern) {
              if (newPattern != null) {
                print("pattern ID!!:"+newPattern.id);
                print("PAttern nom!!:"+newPattern.nom);
                onPatternSelected(newPattern);
              }
            },
          ),
        ),
      ),
    );
  }
}
