import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';

class MarketMenu extends StatelessWidget {
  const MarketMenu({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Column(
      children: [
        const DiscountCard(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 2, // Only 2 custom tiles
              
              itemBuilder: (context, index) {
                if (index == 0) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomPage1(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Weather",
                                  style: TextStyle(
                                      color: TColor.text,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "View more >",
                                  maxLines: 2,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: const Color(0xff212121)
                                        .withOpacity(0.3),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              'assets/images/weather.jpg',
                              width: media.width * 0.35,
                              height: media.width * 0.15 * 1.6,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (index == 1) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomPage2(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Financial Literacy",
                                  style: TextStyle(
                                      color: TColor.text,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "View more >",
                                  maxLines: 2,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: const Color(0xff212121)
                                        .withOpacity(0.3),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              'assets/images/financialcover.jpg',
                              width: media.width * 0.35,
                              height: media.width * 0.15 * 1.6,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink(); // Fallback (shouldn't be hit)
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CustomPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Custom Page 1")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load Weather data. Please try again.',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Custom Page 2")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load Financial Literacy information.',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscountCard extends StatelessWidget {
  const DiscountCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: double.infinity,
            height: 166,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/beyond-meat-mcdonalds.png"),
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 42, 84, 0).withOpacity(0.9),
                    kPrimaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: "A Farmer with Knowledge is \n",
                              style: TextStyle(fontSize: 16),
                            ),
                            TextSpan(
                              text: "90% \n",
                              style: TextStyle(
                                fontSize: 43,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "Good torwards Good harvest",
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
