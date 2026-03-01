import 'package:flutter/material.dart';
import '../model/berth_schedule_model.dart';

class BerthDetailsScreen extends StatelessWidget {
  final BerthScheduleModel schedule;

  const BerthDetailsScreen({Key? key, required this.schedule})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getBadgeColor(String phase) {
      if (phase.toLowerCase() == 'inbound') return Colors.blue[100]!;
      if (phase.toLowerCase() == 'departed') return Colors.red[100]!;
      return Colors.grey[200]!;
    }

    Color getBadgeTextColor(String phase) {
      if (phase.toLowerCase() == 'inbound') return Colors.blue[900]!;
      if (phase.toLowerCase() == 'departed') return Colors.red[900]!;
      return Colors.grey[800]!;
    }

    return Scaffold(
      backgroundColor:
          Colors.white, // Lighter background color conforming to mockup
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vessel Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getBadgeColor(schedule.phase),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                schedule.phase,
                style: TextStyle(
                  color: getBadgeTextColor(schedule.phase),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.directions_boat_outlined,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    schedule.vesselName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // OVERVIEW Section
            const Text(
              'OVERVIEW',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Visit', schedule.visit),
            const Divider(height: 24, color: Colors.black12),
            _buildDetailRow('Line', schedule.line),
            const Divider(height: 24, color: Colors.black12),
            _buildDetailRow('Facility', schedule.facility),
            const Divider(height: 24, color: Colors.black12),
            _buildDetailRow('Vessel class', schedule.vesselClass),

            const SizedBox(height: 32),

            // VOYAGE Section
            const Text(
              'VOYAGE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildBoxedValue('I/B Vyg', schedule.ibVyg)),
                const SizedBox(width: 16),
                Expanded(child: _buildBoxedValue('O/B Vyg', schedule.obVyg)),
              ],
            ),

            const SizedBox(height: 32),

            // SCHEDULE Section
            const Text(
              'SCHEDULE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildScheduleBox(
                        'ETA',
                        schedule.eta,
                        'ATA',
                        schedule.ata,
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.sync_alt, color: Colors.blue, size: 20),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildScheduleBox(
                        'ETD',
                        schedule.etd,
                        'ATD',
                        schedule.atd,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoxedValue(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleBox(
    String label1,
    String val1,
    String label2,
    String val2,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label1,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            (val1 == 'null') ? 'N/A' : val1,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            label2,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            (val2 == 'null') ? 'N/A' : val2,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
