from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):
    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name='QRCodeCard',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('code', models.CharField(blank=True, max_length=64, unique=True)),
                ('status', models.CharField(choices=[('pending', 'En attente'), ('validated', 'Validé')], default='pending', max_length=20)),
                ('center_name', models.CharField(blank=True, max_length=255)),
                ('center_city', models.CharField(blank=True, max_length=255)),
                ('image', models.ImageField(blank=True, upload_to='qr_codes/')),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
            options={
                'ordering': ('-created_at',),
            },
        ),
    ]

